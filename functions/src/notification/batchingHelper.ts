import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { NotificationHelper, NotificationPayload } from './NotificationHelper';

const db = admin.firestore();

/**
 * NOTIFICATION BATCHING SYSTEM
 * Groups notifications to prevent notification spam
 * Sends summary notifications instead of individual pushes
 */
export class NotificationBatchingHelper {
  // Batch configuration
  static readonly BATCH_WINDOW_MINUTES = 5;
  static readonly MAX_NOTIFICATIONS_PER_BATCH = 5;
  static readonly BATCH_CHECK_INTERVAL_MS = 60000; // Check every minute

  /**
   * Queue a notification for batching
   * If batch threshold reached, send immediately
   */
  static async queueNotificationForBatching(
    userId: string,
    payload: NotificationPayload
  ): Promise<void> {
    try {
      // Create queue document
      const queueRef = db
        .collection('users')
        .doc(userId)
        .collection('notificationQueue')
        .doc();

      await queueRef.set({
        userId,
        payload,
        queuedAt: admin.firestore.FieldValue.serverTimestamp(),
        processed: false,
      });

      // Check if we should send batch now
      await this.checkAndSendBatch(userId);

      functions.logger.info(`Notification queued for user ${userId}`);
    } catch (error) {
      functions.logger.error(
        `Error queuing notification for user ${userId}:`,
        error
      );
    }
  }

  /**
   * Check if batch should be sent based on:
   * - Number of queued notifications (>= MAX_NOTIFICATIONS_PER_BATCH)
   * - Time since first notification (>= BATCH_WINDOW_MINUTES)
   */
  static async checkAndSendBatch(userId: string): Promise<void> {
    try {
      const queuedNotifications = await db
        .collection('users')
        .doc(userId)
        .collection('notificationQueue')
        .where('processed', '==', false)
        .orderBy('queuedAt', 'asc')
        .get();

      if (queuedNotifications.empty) {
        return;
      }

      const notificationCount = queuedNotifications.size;

      // Check if we should send batch
      if (notificationCount >= this.MAX_NOTIFICATIONS_PER_BATCH) {
        await this.sendBatchAndClear(userId, queuedNotifications.docs);
        return;
      }

      // Check time-based threshold
      const oldestNotification = queuedNotifications.docs[0];
      const oldestTime = (
        oldestNotification.get('queuedAt') as admin.firestore.Timestamp
      ).toDate();
      const timeSinceOldest = Date.now() - oldestTime.getTime();
      const windowMs = this.BATCH_WINDOW_MINUTES * 60 * 1000;

      if (timeSinceOldest >= windowMs) {
        await this.sendBatchAndClear(userId, queuedNotifications.docs);
        return;
      }

      functions.logger.info(
        `Batch accumulating for user ${userId}: ${notificationCount}/${this.MAX_NOTIFICATIONS_PER_BATCH}`
      );
    } catch (error) {
      functions.logger.error(
        `Error checking batch for user ${userId}:`,
        error
      );
    }
  }

  /**
   * Send batch as summary notification and clear queue
   */
  static async sendBatchAndClear(
    userId: string,
    queuedDocs: admin.firestore.QueryDocumentSnapshot[]
  ): Promise<void> {
    try {
      if (queuedDocs.length === 0) {
        return;
      }

      // Extract payloads
      const payloads: NotificationPayload[] = queuedDocs.map((doc) =>
        doc.get('payload') as NotificationPayload
      );

      // Generate summary
      const summary = this.generateBatchSummary(payloads);

      functions.logger.info(
        `Sending batch summary to user ${userId}: ${summary.title}`
      );

      // Create batch summary notification
      const batchPayload: NotificationPayload = {
        title: summary.title,
        body: summary.body,
        type: 'batch_summary',
        entityId: `batch_${Date.now()}`,
        data: {
          batchSize: payloads.length.toString(),
          notificationTypes: summary.types.join(','),
        },
      };

      // Send combined notification
      await NotificationHelper.createAndSendNotification(userId, batchPayload);

      // Mark all as processed and archive
      const batch = db.batch();

      for (const doc of queuedDocs) {
        batch.update(doc.ref, {
          processed: true,
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Archive to history
        await db
          .collection('users')
          .doc(userId)
          .collection('notificationHistory')
          .doc()
          .set({
            ...doc.data(),
            batchSentAt: admin.firestore.FieldValue.serverTimestamp(),
          });
      }

      await batch.commit();

      functions.logger.info(
        `Batch processed and archived for user ${userId}: ${queuedDocs.length} notifications`
      );
    } catch (error) {
      functions.logger.error(
        `Error sending batch for user ${userId}:`,
        error
      );
    }
  }

  /**
   * Generate user-friendly summary from multiple notifications
   */
  private static generateBatchSummary(payloads: NotificationPayload[]): {
    title: string;
    body: string;
    types: string[];
  } {
    const types = [...new Set(payloads.map((p) => p.type))];
    const typeLabels = types.map((t) => this.getTypeLabel(t));
    const count = payloads.length;

    if (count === 1) {
      return {
        title: payloads[0].payload?.title || 'Bildirim',
        body: payloads[0].body || '',
        types,
      };
    }

    if (types.length === 1) {
      // All same type - create specific summary
      const type = types[0];
      let label = typeLabels[0];

      const summaryMap: { [key: string]: string } = {
        new_message: `${count} yeni mesajın var`,
        new_trade_offer: `${count} yeni ticari teklifin var`,
        new_item_from_vendor: `${count} takip ettiğin satıcıdan yeni ürün`,
        new_rating: `${count} yeni değerlendirmen var`,
        new_follow: `${count} yeni takipçin var`,
      };

      const summary = summaryMap[type] || `${count} yeni ${label}`;

      return {
        title: '📱 Bildirimler',
        body: summary,
        types,
      };
    }

    // Mixed types - generic summary
    return {
      title: '📱 Bildirimler',
      body: `${count} yeni bildirim: ${typeLabels.join(', ')}`,
      types,
    };
  }

  /**
   * Get label for notification type
   */
  private static getTypeLabel(type: string): string {
    const labels: { [key: string]: string } = {
      new_message: 'mesaj',
      new_trade_offer: 'ticari teklif',
      trade_accepted: 'kabul edilen teklif',
      new_item_from_vendor: 'yeni ürün',
      new_rating: 'değerlendirme',
      new_follow: 'takipçi',
      campaign_notification: 'kampanya',
      promotion_notification: 'promosyon',
      warning_notification: 'uyarı',
      system_notification: 'sistem bildirimi',
    };

    return labels[type] || type;
  }

  /**
   * Get pending batch size for user
   */
  static async getPendingBatchSize(userId: string): Promise<number> {
    try {
      const snapshot = await db
        .collection('users')
        .doc(userId)
        .collection('notificationQueue')
        .where('processed', '==', false)
        .count()
        .get();

      return snapshot.data().count;
    } catch (error) {
      functions.logger.error(
        `Error getting batch size for user ${userId}:`,
        error
      );
      return 0;
    }
  }

  /**
   * Clear old notifications from queue (older than 24 hours)
   */
  static async cleanupOldNotifications(): Promise<void> {
    try {
      const cutoffTime = new Date(Date.now() - 24 * 60 * 60 * 1000);

      // This would require a more complex query - for now just log
      functions.logger.info(
        `Cleanup scheduled for notifications older than ${cutoffTime}`
      );

      // TODO: Implement with Firestore admin operations or scheduled function
    } catch (error) {
      functions.logger.error('Error in cleanup:', error);
    }
  }
}
