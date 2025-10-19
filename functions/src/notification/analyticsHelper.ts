import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * NOTIFICATION ANALYTICS HELPER
 * Tracks notification events and generates analytics
 */
export type NotificationEvent = 'sent' | 'delivered' | 'opened' | 'dismissed' | 'failed';

export interface NotificationAnalyticsEvent {
  userId: string;
  event: NotificationEvent;
  type: string; // Notification type
  entityId: string;
  timestamp: admin.firestore.Timestamp;
  metadata?: {
    platform?: string;
    deviceId?: string;
    errorCode?: string;
    errorMessage?: string;
    delayMs?: number;
  };
}

export class AnalyticsHelper {
  /**
   * Log a notification event
   */
  static async logNotificationEvent(
    userId: string,
    event: NotificationEvent,
    type: string,
    entityId: string,
    metadata?: Record<string, any>
  ): Promise<string> {
    try {
      const eventRef = await db
        .collection('notificationAnalytics')
        .doc()
        .set({
          userId,
          event,
          type,
          entityId,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          metadata: metadata || {},
        });

      functions.logger.info(
        `Analytics event logged: ${event} for user ${userId}, type ${type}`
      );

      return eventRef.id;
    } catch (error) {
      functions.logger.error(
        `Error logging analytics event for user ${userId}:`,
        error
      );
      throw error;
    }
  }

  /**
   * Get notification statistics for a user
   */
  static async getUserStats(userId: string, daysBack: number = 7): Promise<{
    totalSent: number;
    totalOpened: number;
    totalDismissed: number;
    totalFailed: number;
    openRate: number;
    dismissRate: number;
    failureRate: number;
    byType: { [key: string]: number };
  }> {
    try {
      const cutoffDate = new Date(Date.now() - daysBack * 24 * 60 * 60 * 1000);

      const snapshot = await db
        .collection('notificationAnalytics')
        .where('userId', '==', userId)
        .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(cutoffDate))
        .get();

      const events = snapshot.docs.map((doc) => doc.data());

      const stats = {
        totalSent: events.filter((e) => e.event === 'sent').length,
        totalOpened: events.filter((e) => e.event === 'opened').length,
        totalDismissed: events.filter((e) => e.event === 'dismissed').length,
        totalFailed: events.filter((e) => e.event === 'failed').length,
        openRate: 0,
        dismissRate: 0,
        failureRate: 0,
        byType: {} as { [key: string]: number },
      };

      // Calculate rates
      if (stats.totalSent > 0) {
        stats.openRate = Math.round((stats.totalOpened / stats.totalSent) * 100);
        stats.dismissRate = Math.round((stats.totalDismissed / stats.totalSent) * 100);
        stats.failureRate = Math.round((stats.totalFailed / stats.totalSent) * 100);
      }

      // Count by type
      for (const event of events) {
        const type = event.type as string;
        stats.byType[type] = (stats.byType[type] || 0) + 1;
      }

      return stats;
    } catch (error) {
      functions.logger.error(
        `Error getting stats for user ${userId}:`,
        error
      );
      throw error;
    }
  }

  /**
   * Get system-wide analytics
   */
  static async getSystemStats(daysBack: number = 7): Promise<{
    totalNotifications: number;
    totalUsers: number;
    averageOpenRate: number;
    topTypes: Array<{ type: string; count: number }>;
    failureRate: number;
  }> {
    try {
      const cutoffDate = new Date(Date.now() - daysBack * 24 * 60 * 60 * 1000);

      const snapshot = await db
        .collection('notificationAnalytics')
        .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(cutoffDate))
        .get();

      const events = snapshot.docs.map((doc) => doc.data());

      const uniqueUsers = new Set(events.map((e) => e.userId)).size;
      const sentCount = events.filter((e) => e.event === 'sent').length;
      const openedCount = events.filter((e) => e.event === 'opened').length;
      const failedCount = events.filter((e) => e.event === 'failed').length;

      // Count by type
      const typeCount: { [key: string]: number } = {};
      for (const event of events) {
        if (event.event === 'sent') {
          const type = event.type as string;
          typeCount[type] = (typeCount[type] || 0) + 1;
        }
      }

      const topTypes = Object.entries(typeCount)
        .map(([type, count]) => ({ type, count }))
        .sort((a, b) => b.count - a.count)
        .slice(0, 10);

      return {
        totalNotifications: sentCount,
        totalUsers: uniqueUsers,
        averageOpenRate: sentCount > 0 ? Math.round((openedCount / sentCount) * 100) : 0,
        topTypes,
        failureRate: sentCount > 0 ? Math.round((failedCount / sentCount) * 100) : 0,
      };
    } catch (error) {
      functions.logger.error('Error getting system stats:', error);
      throw error;
    }
  }

  /**
   * Get notification performance by type
   */
  static async getPerformanceByType(
    type: string,
    daysBack: number = 7
  ): Promise<{
    type: string;
    sent: number;
    opened: number;
    dismissed: number;
    failed: number;
    openRate: number;
  }> {
    try {
      const cutoffDate = new Date(Date.now() - daysBack * 24 * 60 * 60 * 1000);

      const snapshot = await db
        .collection('notificationAnalytics')
        .where('type', '==', type)
        .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(cutoffDate))
        .get();

      const events = snapshot.docs.map((doc) => doc.data());

      const sent = events.filter((e) => e.event === 'sent').length;
      const opened = events.filter((e) => e.event === 'opened').length;
      const dismissed = events.filter((e) => e.event === 'dismissed').length;
      const failed = events.filter((e) => e.event === 'failed').length;

      return {
        type,
        sent,
        opened,
        dismissed,
        failed,
        openRate: sent > 0 ? Math.round((opened / sent) * 100) : 0,
      };
    } catch (error) {
      functions.logger.error(
        `Error getting performance for type ${type}:`,
        error
      );
      throw error;
    }
  }

  /**
   * Archive old analytics (older than 30 days)
   * Free up space in main collection
   */
  static async archiveOldAnalytics(): Promise<number> {
    try {
      const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

      const snapshot = await db
        .collection('notificationAnalytics')
        .where('timestamp', '<', admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
        .limit(1000)
        .get();

      if (snapshot.empty) {
        functions.logger.info('No old analytics to archive');
        return 0;
      }

      const batch = db.batch();
      let archivedCount = 0;

      for (const doc of snapshot.docs) {
        const data = doc.data();

        // Archive to history collection
        await db
          .collection('notificationAnalyticsArchive')
          .doc()
          .set({
            ...data,
            archivedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

        // Delete from main collection
        batch.delete(doc.ref);
        archivedCount++;
      }

      await batch.commit();

      functions.logger.info(
        `Archived ${archivedCount} old analytics events`
      );

      return archivedCount;
    } catch (error) {
      functions.logger.error('Error archiving old analytics:', error);
      return 0;
    }
  }

  /**
   * Get daily trend data
   */
  static async getDailyTrend(daysBack: number = 7): Promise<
    Array<{
      date: string;
      sent: number;
      opened: number;
      dismissed: number;
      failed: number;
    }>
  > {
    try {
      const cutoffDate = new Date(Date.now() - daysBack * 24 * 60 * 60 * 1000);

      const snapshot = await db
        .collection('notificationAnalytics')
        .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(cutoffDate))
        .get();

      const dailyData: {
        [key: string]: {
          sent: number;
          opened: number;
          dismissed: number;
          failed: number;
        };
      } = {};

      for (const doc of snapshot.docs) {
        const data = doc.data();
        const date = (
          data.timestamp as admin.firestore.Timestamp
        ).toDate();
        const dateStr = date.toISOString().split('T')[0]; // YYYY-MM-DD

        if (!dailyData[dateStr]) {
          dailyData[dateStr] = { sent: 0, opened: 0, dismissed: 0, failed: 0 };
        }

        const event = data.event as NotificationEvent;
        if (event === 'sent') dailyData[dateStr].sent++;
        else if (event === 'opened') dailyData[dateStr].opened++;
        else if (event === 'dismissed') dailyData[dateStr].dismissed++;
        else if (event === 'failed') dailyData[dateStr].failed++;
      }

      // Sort by date
      return Object.entries(dailyData)
        .map(([date, data]) => ({ date, ...data }))
        .sort((a, b) => a.date.localeCompare(b.date));
    } catch (error) {
      functions.logger.error('Error getting daily trend:', error);
      throw error;
    }
  }
}
