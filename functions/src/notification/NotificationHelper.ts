import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export interface NotificationPayload {
  title: string;
  body: string;
  type: string;
  entityId: string;
  imageUrl?: string;
  data?: Record<string, string>;
}

/**
 * CENTRALIZED NOTIFICATION HELPER - NO CODE DUPLICATION
 * All notification logic goes through this helper
 */
export class NotificationHelper {
  /**
   * Get all FCM tokens for a user
   */
  static async getUserTokens(userId: string): Promise<string[]> {
    try {
      const tokensSnap = await db
        .collection('users')
        .doc(userId)
        .collection('fcmTokens')
        .get();

      if (tokensSnap.empty) {
        functions.logger.info(`No tokens found for user ${userId}`);
        return [];
      }

      return tokensSnap.docs
        .map((d) => (d.get('token') as string) ?? d.id)
        .filter(Boolean);
    } catch (error) {
      functions.logger.error(`Error getting tokens for user ${userId}:`, error);
      return [];
    }
  }

  /**
   * Check if user has notification preferences enabled for a type
   */
  static async checkNotificationPreference(
    userId: string,
    notificationType: string
  ): Promise<boolean> {
    try {
      const userDoc = await db.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        functions.logger.warn(`User document not found for ${userId}`);
        return true; // Default to enabled
      }

      const userData = userDoc.data();

      // Check global notifications enabled
      const globalEnabled = userData?.notificationsEnabled ?? true;
      if (!globalEnabled) {
        return false;
      }

      // Check type-specific preference
      const preferences = userData?.notificationPreferences || {};
      const typeEnabled = preferences[notificationType] ?? true;

      return typeEnabled;
    } catch (error) {
      functions.logger.error(
        `Error checking preference for user ${userId}, type ${notificationType}:`,
        error
      );
      return true; // Default to enabled on error
    }
  }

  /**
   * Create notification document in user's subcollection
   */
  static async createNotificationDocument(
    userId: string,
    payload: NotificationPayload
  ): Promise<string> {
    try {
      const notificationId = `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      const notificationRef = db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId);

      await notificationRef.set({
        userId,
        type: payload.type,
        title: payload.title,
        body: payload.body,
        imageUrl: payload.imageUrl || null,
        isRead: false,
        entityId: payload.entityId,
        data: payload.data || {},
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return notificationId;
    } catch (error) {
      functions.logger.error(
        `Error creating notification document for user ${userId}:`,
        error
      );
      throw error;
    }
  }

  /**
   * Send push notification with retry logic and error handling
   */
  static async sendMulticastWithRetry(
    tokens: string[],
    notification: admin.messaging.Notification,
    data?: Record<string, string>,
    maxRetries: number = 3
  ): Promise<{ successCount: number; failureCount: number; invalidTokens: string[] }> {
    if (!tokens || tokens.length === 0) {
      functions.logger.info('No tokens to send notification');
      return { successCount: 0, failureCount: 0, invalidTokens: [] };
    }

    const invalidTokens: string[] = [];
    let attempt = 1;

    while (attempt <= maxRetries) {
      try {
        const payload: admin.messaging.MulticastMessage = {
          tokens,
          notification,
          data: data || {},
        };

        const res = await admin.messaging().sendMulticast(payload);

        functions.logger.info(
          `Push notification sent (attempt ${attempt}/${maxRetries})`,
          {
            successCount: res.successCount,
            failureCount: res.failureCount,
            tokenCount: tokens.length,
          }
        );

        // Collect invalid tokens for cleanup
        if (res.failureCount > 0) {
          res.responses.forEach((resp, idx) => {
            if (!resp.success && resp.error) {
              const errorCode = resp.error.code;
              if (
                errorCode === 'messaging/invalid-registration-token' ||
                errorCode === 'messaging/registration-token-not-registered'
              ) {
                invalidTokens.push(tokens[idx]);
              }
            }
          });
        }

        return {
          successCount: res.successCount,
          failureCount: res.failureCount,
          invalidTokens,
        };
      } catch (error: any) {
        functions.logger.warn(
          `Error sending notification (attempt ${attempt}/${maxRetries}):`,
          error
        );

        if (attempt === maxRetries) {
          functions.logger.error(
            `Failed to send notification after ${maxRetries} attempts`,
            error
          );
          throw error;
        }

        // Exponential backoff: 1s, 2s, 4s
        const delay = Math.pow(2, attempt - 1) * 1000;
        await new Promise((resolve) => setTimeout(resolve, delay));

        attempt++;
      }
    }

    return { successCount: 0, failureCount: tokens.length, invalidTokens };
  }

  /**
   * Clean up invalid tokens from Firestore
   */
  static async cleanupInvalidTokens(userId: string, invalidTokens: string[]): Promise<void> {
    if (!invalidTokens || invalidTokens.length === 0) {
      return;
    }

    try {
      const batch = db.batch();

      for (const token of invalidTokens) {
        const tokenRef = db
          .collection('users')
          .doc(userId)
          .collection('fcmTokens')
          .doc(token);

        batch.delete(tokenRef);
      }

      await batch.commit();

      functions.logger.info(
        `Cleaned up ${invalidTokens.length} invalid tokens for user ${userId}`
      );
    } catch (error) {
      functions.logger.error(`Error cleaning up tokens for user ${userId}:`, error);
    }
  }

  /**
   * Create notification and send push - combined operation
   */
  static async createAndSendNotification(
    userId: string,
    payload: NotificationPayload
  ): Promise<void> {
    try {
      // Check notification preferences
      const isEnabled = await this.checkNotificationPreference(userId, payload.type);

      if (!isEnabled) {
        functions.logger.info(
          `Notifications disabled for user ${userId}, type ${payload.type}`
        );
        return;
      }

      // Create notification document (always)
      const notificationId = await this.createNotificationDocument(userId, payload);
      functions.logger.info(
        `Notification document created: ${notificationId} for user ${userId}`
      );

      // Get user tokens
      const tokens = await this.getUserTokens(userId);

      if (tokens.length === 0) {
        functions.logger.warn(`No tokens found for user ${userId}`);
        return;
      }

      // Send push notification with retry
      const notification: admin.messaging.Notification = {
        title: payload.title,
        body: payload.body,
      };

      const { invalidTokens } = await this.sendMulticastWithRetry(
        tokens,
        notification,
        {
          type: payload.type,
          entityId: payload.entityId,
          ...(payload.data || {}),
        }
      );

      // Clean up invalid tokens
      if (invalidTokens.length > 0) {
        await this.cleanupInvalidTokens(userId, invalidTokens);
      }
    } catch (error) {
      functions.logger.error(
        `Error creating and sending notification for user ${userId}:`,
        error
      );
      // Log to Dead Letter Queue for later processing
      await this.logToDeadLetterQueue(userId, payload, error);
    }
  }

  /**
   * Check if notification was recently sent (deduplication)
   */
  static async isDuplicateNotification(
    userId: string,
    type: string,
    entityId: string,
    windowMinutes: number = 5
  ): Promise<boolean> {
    try {
      const cutoffTime = new Date(Date.now() - windowMinutes * 60 * 1000);

      const existingNotification = await db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('type', '==', type)
        .where('entityId', '==', entityId)
        .where('createdAt', '>=', cutoffTime)
        .limit(1)
        .get();

      return !existingNotification.empty;
    } catch (error) {
      functions.logger.error(
        `Error checking duplicate notification for user ${userId}:`,
        error
      );
      return false; // Don't skip on error
    }
  }

  /**
   * Log failed notification to Dead Letter Queue
   */
  static async logToDeadLetterQueue(
    userId: string,
    payload: NotificationPayload,
    error: any
  ): Promise<void> {
    try {
      await db.collection('failed_notifications').doc().set({
        userId,
        payload,
        error: error?.message || String(error),
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        retryCount: 0,
        status: 'pending',
      });

      functions.logger.info(`Logged failed notification to Dead Letter Queue for user ${userId}`);
    } catch (dlqError) {
      functions.logger.error(`Error logging to Dead Letter Queue:`, dlqError);
    }
  }

  /**
   * Batch notifications for a user (don't send individually, send as summary)
   */
  static async getBatchSummary(userId: string, maxNotifications: number = 5): Promise<{
    count: number;
    notifications: any[];
    summary: string;
  } | null> {
    try {
      const recentNotifications = await db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', '==', false)
        .orderBy('createdAt', 'desc')
        .limit(maxNotifications)
        .get();

      if (recentNotifications.empty) {
        return null;
      }

      const notifications = recentNotifications.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));

      // Create summary based on notification types
      const types = notifications.map((n) => n.type);
      const uniqueTypes = [...new Set(types)];

      let summary = `${notifications.length} yeni bildirim`;
      if (notifications.length > 1 && uniqueTypes.length === 1) {
        summary = `${notifications.length} yeni ${this.getTypeLabel(uniqueTypes[0])}`;
      }

      return {
        count: notifications.length,
        notifications,
        summary,
      };
    } catch (error) {
      functions.logger.error(`Error getting batch summary for user ${userId}:`, error);
      return null;
    }
  }

  /**
   * Get user-friendly label for notification type
   */
  private static getTypeLabel(type: string): string {
    const labels: Record<string, string> = {
      new_message: 'mesaj',
      new_trade_offer: 'ticari teklif',
      trade_accepted: 'kabul edilen ticari işlem',
      new_item_from_vendor: 'yeni ürün',
      new_rating: 'yeni değerlendirme',
      new_follow: 'yeni takipçi',
      campaign_notification: 'kampanya',
      promotion_notification: 'promosyon',
      warning_notification: 'uyarı',
      system_notification: 'sistem bildirimi',
    };
    return labels[type] || type;
  }

  /**
   * Update analytics for notification
   */
  static async logNotificationEvent(
    userId: string,
    event: 'sent' | 'delivered' | 'clicked' | 'dismissed' | 'failed',
    type: string,
    entityId: string
  ): Promise<void> {
    try {
      await db.collection('notification_analytics').doc().set({
        userId,
        event,
        type,
        entityId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (error) {
      functions.logger.error(`Error logging notification event:`, error);
    }
  }
}
