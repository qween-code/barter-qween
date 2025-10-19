import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * DEAD LETTER QUEUE (DLQ) HELPER
 * Manages failed notifications for later retry or analysis
 */
export interface DLQEntry {
  userId: string;
  payload: Record<string, any>;
  error: string;
  timestamp: admin.firestore.Timestamp;
  retryCount: number;
  lastRetryAt?: admin.firestore.Timestamp;
  status: 'pending' | 'failed' | 'resolved' | 'abandoned';
  failureReason: string;
  nextRetryAt?: admin.firestore.Timestamp;
}

export class DeadLetterQueueHelper {
  /**
   * Add notification to Dead Letter Queue
   */
  static async addToQueue(
    userId: string,
    payload: Record<string, any>,
    error: any,
    failureReason: string
  ): Promise<string> {
    try {
      const dlqRef = await db.collection('deadLetterQueue').doc().set({
        userId,
        payload,
        error: error?.message || String(error),
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        retryCount: 0,
        status: 'pending',
        failureReason,
        nextRetryAt: admin.firestore.Timestamp.fromDate(
          new Date(Date.now() + 5 * 60 * 1000) // Retry after 5 minutes
        ),
      });

      functions.logger.info(
        `Added to DLQ for user ${userId}: ${failureReason}`
      );

      return dlqRef.id;
    } catch (error) {
      functions.logger.error(
        `Error adding to DLQ for user ${userId}:`,
        error
      );
      throw error;
    }
  }

  /**
   * Get pending items from Dead Letter Queue
   */
  static async getPendingItems(
    limit: number = 100
  ): Promise<Array<{ id: string; data: DLQEntry }>> {
    try {
      const snapshot = await db
        .collection('deadLetterQueue')
        .where('status', '==', 'pending')
        .where(
          'nextRetryAt',
          '<=',
          admin.firestore.Timestamp.now()
        )
        .where('retryCount', '<', 3)
        .orderBy('nextRetryAt', 'asc')
        .limit(limit)
        .get();

      return snapshot.docs.map((doc) => ({
        id: doc.id,
        data: doc.data() as DLQEntry,
      }));
    } catch (error) {
      functions.logger.error('Error getting pending DLQ items:', error);
      return [];
    }
  }

  /**
   * Retry a failed notification
   */
  static async retryNotification(
    dlqId: string,
    notificationHelper: any // NotificationHelper
  ): Promise<boolean> {
    try {
      const dlqDoc = await db.collection('deadLetterQueue').doc(dlqId).get();

      if (!dlqDoc.exists) {
        functions.logger.warn(`DLQ entry not found: ${dlqId}`);
        return false;
      }

      const dlqData = dlqDoc.data() as DLQEntry;

      // Check retry limit
      if (dlqData.retryCount >= 3) {
        await db.collection('deadLetterQueue').doc(dlqId).update({
          status: 'abandoned',
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        functions.logger.info(
          `DLQ entry abandoned (max retries): ${dlqId}`
        );

        return false;
      }

      // Attempt retry
      try {
        await notificationHelper.createAndSendNotification(
          dlqData.userId,
          dlqData.payload
        );

        // Success - mark as resolved
        await db.collection('deadLetterQueue').doc(dlqId).update({
          status: 'resolved',
          resolvedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        functions.logger.info(
          `DLQ entry resolved after retry: ${dlqId}`
        );

        return true;
      } catch (retryError) {
        // Failed again - update retry count and schedule next retry
        const exponentialBackoff = Math.pow(2, dlqData.retryCount + 1) * 60 * 1000; // 2min, 4min, 8min

        await db.collection('deadLetterQueue').doc(dlqId).update({
          retryCount: admin.firestore.FieldValue.increment(1),
          lastRetryAt: admin.firestore.FieldValue.serverTimestamp(),
          error: retryError instanceof Error ? retryError.message : String(retryError),
          nextRetryAt: admin.firestore.Timestamp.fromDate(
            new Date(Date.now() + exponentialBackoff)
          ),
        });

        functions.logger.warn(
          `DLQ entry retry failed (attempt ${dlqData.retryCount + 1}): ${dlqId}`
        );

        return false;
      }
    } catch (error) {
      functions.logger.error(`Error retrying DLQ notification ${dlqId}:`, error);
      return false;
    }
  }

  /**
   * Get DLQ statistics
   */
  static async getQueueStats(): Promise<{
    pending: number;
    failed: number;
    resolved: number;
    abandoned: number;
    total: number;
  }> {
    try {
      const snapshot = await db.collection('deadLetterQueue').get();

      const stats = {
        pending: 0,
        failed: 0,
        resolved: 0,
        abandoned: 0,
        total: snapshot.size,
      };

      for (const doc of snapshot.docs) {
        const status = doc.get('status') as string;
        if (status === 'pending') stats.pending++;
        else if (status === 'failed') stats.failed++;
        else if (status === 'resolved') stats.resolved++;
        else if (status === 'abandoned') stats.abandoned++;
      }

      return stats;
    } catch (error) {
      functions.logger.error('Error getting DLQ stats:', error);
      return { pending: 0, failed: 0, resolved: 0, abandoned: 0, total: 0 };
    }
  }

  /**
   * Get failures by reason
   */
  static async getFailureAnalysis(): Promise<
    Array<{ reason: string; count: number; percentage: number }>
  > {
    try {
      const snapshot = await db
        .collection('deadLetterQueue')
        .where('status', 'in', ['failed', 'abandoned'])
        .get();

      const reasonCounts: { [key: string]: number } = {};
      const total = snapshot.size;

      for (const doc of snapshot.docs) {
        const reason = (doc.get('failureReason') as string) || 'unknown';
        reasonCounts[reason] = (reasonCounts[reason] || 0) + 1;
      }

      const analysis = Object.entries(reasonCounts)
        .map(([reason, count]) => ({
          reason,
          count,
          percentage: Math.round((count / total) * 100),
        }))
        .sort((a, b) => b.count - a.count);

      return analysis;
    } catch (error) {
      functions.logger.error('Error analyzing DLQ failures:', error);
      return [];
    }
  }

  /**
   * Clear resolved and abandoned items older than 7 days
   */
  static async cleanupOldEntries(): Promise<number> {
    try {
      const sevenDaysAgo = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
      );

      const snapshot = await db
        .collection('deadLetterQueue')
        .where('status', 'in', ['resolved', 'abandoned'])
        .where('timestamp', '<', sevenDaysAgo)
        .limit(1000)
        .get();

      const batch = db.batch();
      let deletedCount = 0;

      for (const doc of snapshot.docs) {
        batch.delete(doc.ref);
        deletedCount++;
      }

      await batch.commit();

      functions.logger.info(
        `Cleaned up ${deletedCount} old DLQ entries`
      );

      return deletedCount;
    } catch (error) {
      functions.logger.error('Error cleaning up old DLQ entries:', error);
      return 0;
    }
  }

  /**
   * Manually resolve a DLQ entry (admin action)
   */
  static async manuallyResolve(dlqId: string, notes: string): Promise<void> {
    try {
      await db.collection('deadLetterQueue').doc(dlqId).update({
        status: 'resolved',
        resolvedAt: admin.firestore.FieldValue.serverTimestamp(),
        adminNotes: notes,
      });

      functions.logger.info(
        `DLQ entry manually resolved: ${dlqId}`
      );
    } catch (error) {
      functions.logger.error(
        `Error manually resolving DLQ entry ${dlqId}:`,
        error
      );
      throw error;
    }
  }

  /**
   * Export DLQ for analysis
   */
  static async exportForAnalysis(
    status?: string
  ): Promise<Array<Record<string, any>>> {
    try {
      let query = db.collection('deadLetterQueue') as admin.firestore.Query;

      if (status) {
        query = query.where('status', '==', status);
      }

      const snapshot = await query
        .orderBy('timestamp', 'desc')
        .limit(10000)
        .get();

      return snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));
    } catch (error) {
      functions.logger.error('Error exporting DLQ for analysis:', error);
      return [];
    }
  }
}
