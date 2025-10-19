import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { NotificationHelper, NotificationPayload } from './NotificationHelper';
import { AnalyticsHelper } from './analyticsHelper';
import { DeadLetterQueueHelper } from './deadLetterQueueHelper';
import { PreferencesHelper } from './preferencesHelper';

const db = admin.firestore();

/**
 * ADMIN NOTIFICATION FUNCTIONS
 * Callable functions for admin operations
 */

/**
 * Send broadcast notification to all users or a segment
 * Admin only - check auth token
 */
export const broadcastNotification = functions.https.onCall(
  async (data, context) => {
    // Verify admin
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Must be authenticated'
      );
    }

    try {
      const adminUser = await db.collection('admins').doc(context.auth.uid).get();
      if (!adminUser.exists) {
        throw new functions.https.HttpsError(
          'permission-denied',
          'Not an admin'
        );
      }

      const {
        title,
        body,
        targetUsers,
        targetSegments,
        targetPreferences,
      } = data as {
        title: string;
        body: string;
        targetUsers?: string[]; // Specific user IDs
        targetSegments?: string[]; // 'premium', 'active', etc
        targetPreferences?: string[]; // Notification type preferences to target
      };

      if (!title || !body) {
        throw new functions.https.HttpsError('invalid-argument', 'Missing title or body');
      }

      let usersToNotify: Set<string> = new Set();

      if (targetUsers && targetUsers.length > 0) {
        // Specific users
        targetUsers.forEach((uid) => usersToNotify.add(uid));
      } else {
        // Broadcast to all users
        const allUsersSnapshot = await db
          .collection('users')
          .limit(10000)
          .get();

        allUsersSnapshot.docs.forEach((doc) => {
          usersToNotify.add(doc.id);
        });
      }

      // Filter by segments if specified
      if (targetSegments && targetSegments.length > 0) {
        const filteredUsers: Set<string> = new Set();

        for (const userId of usersToNotify) {
          const userDoc = await db.collection('users').doc(userId).get();
          const userSegments = userDoc.data()?.segments || [];

          const isInSegment = targetSegments.some((seg) =>
            userSegments.includes(seg)
          );

          if (isInSegment) {
            filteredUsers.add(userId);
          }
        }

        usersToNotify = filteredUsers;
      }

      // Send notifications
      let sentCount = 0;
      for (const userId of usersToNotify) {
        try {
          const payload: NotificationPayload = {
            title,
            body,
            type: 'system_notification',
            entityId: `broadcast_${Date.now()}`,
          };

          await NotificationHelper.createAndSendNotification(userId, payload);
          sentCount++;
        } catch (error) {
          functions.logger.error(`Error sending to user ${userId}:`, error);
        }
      }

      functions.logger.info(`Broadcast sent to ${sentCount} users`);

      return {
        success: true,
        sentTo: sentCount,
        message: `Broadcast notification sent to ${sentCount} users`,
      };
    } catch (error) {
      functions.logger.error('Error in broadcastNotification:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Error sending broadcast'
      );
    }
  }
);

/**
 * Get system-wide notification statistics
 * Admin only
 */
export const getNotificationStatistics = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Must be authenticated'
      );
    }

    try {
      const adminUser = await db.collection('admins').doc(context.auth.uid).get();
      if (!adminUser.exists) {
        throw new functions.https.HttpsError(
          'permission-denied',
          'Not an admin'
        );
      }

      const { daysBack } = data as { daysBack?: number };
      const days = daysBack || 7;

      const stats = await AnalyticsHelper.getSystemStats(days);
      const dlqStats = await DeadLetterQueueHelper.getQueueStats();
      const dailyTrend = await AnalyticsHelper.getDailyTrend(days);

      return {
        success: true,
        stats: {
          ...stats,
          dlq: dlqStats,
          trend: dailyTrend,
          daysAnalyzed: days,
          generatedAt: new Date().toISOString(),
        },
      };
    } catch (error) {
      functions.logger.error('Error in getNotificationStatistics:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Error fetching statistics'
      );
    }
  }
);

/**
 * Get Dead Letter Queue items
 * Admin only
 */
export const getDeadLetterQueueItems = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Must be authenticated'
      );
    }

    try {
      const adminUser = await db.collection('admins').doc(context.auth.uid).get();
      if (!adminUser.exists) {
        throw new functions.https.HttpsError(
          'permission-denied',
          'Not an admin'
        );
      }

      const { status } = data as { status?: string };

      const items = await DeadLetterQueueHelper.exportForAnalysis(status);
      const failureAnalysis = await DeadLetterQueueHelper.getFailureAnalysis();
      const dlqStats = await DeadLetterQueueHelper.getQueueStats();

      return {
        success: true,
        items,
        failureAnalysis,
        stats: dlqStats,
      };
    } catch (error) {
      functions.logger.error('Error in getDeadLetterQueueItems:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Error fetching DLQ items'
      );
    }
  }
);

/**
 * Manually resolve a DLQ item
 * Admin only
 */
export const resolveDLQItem = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Must be authenticated'
      );
    }

    try {
      const adminUser = await db.collection('admins').doc(context.auth.uid).get();
      if (!adminUser.exists) {
        throw new functions.https.HttpsError(
          'permission-denied',
          'Not an admin'
        );
      }

      const { dlqId, notes } = data as { dlqId: string; notes: string };

      if (!dlqId) {
        throw new functions.https.HttpsError('invalid-argument', 'Missing dlqId');
      }

      await DeadLetterQueueHelper.manuallyResolve(dlqId, notes || 'Admin resolved');

      return {
        success: true,
        message: `DLQ item ${dlqId} resolved manually`,
      };
    } catch (error) {
      functions.logger.error('Error in resolveDLQItem:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Error resolving DLQ item'
      );
    }
  }
);

/**
 * Get user notification preferences
 * Admin only - for user support
 */
export const getUserPreferences = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Must be authenticated'
      );
    }

    try {
      const adminUser = await db.collection('admins').doc(context.auth.uid).get();
      if (!adminUser.exists) {
        throw new functions.https.HttpsError(
          'permission-denied',
          'Not an admin'
        );
      }

      const { userId } = data as { userId: string };

      if (!userId) {
        throw new functions.https.HttpsError(
          'invalid-argument',
          'Missing userId'
        );
      }

      const preferences = await PreferencesHelper.getUserPreferences(userId);

      return {
        success: true,
        preferences,
      };
    } catch (error) {
      functions.logger.error('Error in getUserPreferences:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Error fetching preferences'
      );
    }
  }
);

/**
 * Get performance of specific notification type
 * Admin only - for analytics
 */
export const getNotificationTypePerformance = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Must be authenticated'
      );
    }

    try {
      const adminUser = await db.collection('admins').doc(context.auth.uid).get();
      if (!adminUser.exists) {
        throw new functions.https.HttpsError(
          'permission-denied',
          'Not an admin'
        );
      }

      const { type, daysBack } = data as {
        type: string;
        daysBack?: number;
      };

      if (!type) {
        throw new functions.https.HttpsError('invalid-argument', 'Missing type');
      }

      const performance = await AnalyticsHelper.getPerformanceByType(
        type,
        daysBack || 7
      );

      return {
        success: true,
        performance,
      };
    } catch (error) {
      functions.logger.error('Error in getNotificationTypePerformance:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Error fetching performance'
      );
    }
  }
);

/**
 * Test send notification to specific user
 * Admin only - for QA/testing
 */
export const testNotification = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Must be authenticated'
      );
    }

    try {
      const adminUser = await db.collection('admins').doc(context.auth.uid).get();
      if (!adminUser.exists) {
        throw new functions.https.HttpsError(
          'permission-denied',
          'Not an admin'
        );
      }

      const { userId, title, body, type } = data as {
        userId: string;
        title: string;
        body: string;
        type?: string;
      };

      if (!userId || !title || !body) {
        throw new functions.https.HttpsError(
          'invalid-argument',
          'Missing required fields'
        );
      }

      const payload: NotificationPayload = {
        title,
        body,
        type: type || 'test_notification',
        entityId: `test_${Date.now()}`,
      };

      await NotificationHelper.createAndSendNotification(userId, payload);

      return {
        success: true,
        message: `Test notification sent to user ${userId}`,
      };
    } catch (error) {
      functions.logger.error('Error in testNotification:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Error sending test notification'
      );
    }
  }
);
