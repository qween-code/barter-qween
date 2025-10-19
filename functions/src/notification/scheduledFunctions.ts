import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { DeadLetterQueueHelper } from './deadLetterQueueHelper';
import { NotificationHelper } from './NotificationHelper';
import { AnalyticsHelper } from './analyticsHelper';

const db = admin.firestore();

/**
 * SCHEDULED CLOUD FUNCTIONS
 * Run on schedule to process DLQ, cleanup, and maintenance
 */

/**
 * Process Dead Letter Queue every 5 minutes
 * Retry failed notifications with exponential backoff
 */
export const processDeadLetterQueue = functions.pubsub
  .schedule('every 5 minutes')
  .onRun(async (context) => {
    functions.logger.info('Processing Dead Letter Queue...');

    try {
      const pendingItems = await DeadLetterQueueHelper.getPendingItems(100);

      if (pendingItems.length === 0) {
        functions.logger.info('No pending items in DLQ');
        return;
      }

      functions.logger.info(`Processing ${pendingItems.length} pending DLQ items`);

      let successCount = 0;
      let failureCount = 0;

      for (const item of pendingItems) {
        try {
          const success = await DeadLetterQueueHelper.retryNotification(
            item.id,
            NotificationHelper
          );

          if (success) {
            successCount++;
            functions.logger.info(`DLQ item resolved: ${item.id}`);
          } else {
            failureCount++;
            functions.logger.warn(`DLQ item retry failed: ${item.id}`);
          }
        } catch (error) {
          failureCount++;
          functions.logger.error(`Error processing DLQ item ${item.id}:`, error);
        }
      }

      functions.logger.info(
        `DLQ processing complete: ${successCount} resolved, ${failureCount} still pending`
      );

      // Log statistics
      await AnalyticsHelper.logNotificationEvent(
        'system',
        'sent',
        'dlq_processing',
        `processed_${pendingItems.length}`
      );

      return;
    } catch (error) {
      functions.logger.error('Error in processDeadLetterQueue:', error);
      throw error;
    }
  });

/**
 * Cleanup old Dead Letter Queue entries daily at 2 AM
 * Delete resolved/abandoned items older than 7 days
 */
export const cleanupDeadLetterQueue = functions.pubsub
  .schedule('0 2 * * *') // 2 AM daily
  .onRun(async (context) => {
    functions.logger.info('Cleaning up old Dead Letter Queue entries...');

    try {
      const deletedCount = await DeadLetterQueueHelper.cleanupOldEntries();
      functions.logger.info(`Cleaned up ${deletedCount} old DLQ entries`);
      return;
    } catch (error) {
      functions.logger.error('Error in cleanupDeadLetterQueue:', error);
      throw error;
    }
  });

/**
 * Archive old analytics daily at 3 AM
 * Move notifications older than 30 days to archive collection
 */
export const archiveOldAnalytics = functions.pubsub
  .schedule('0 3 * * *') // 3 AM daily
  .onRun(async (context) => {
    functions.logger.info('Archiving old analytics...');

    try {
      const archivedCount = await AnalyticsHelper.archiveOldAnalytics();
      functions.logger.info(`Archived ${archivedCount} old analytics events`);
      return;
    } catch (error) {
      functions.logger.error('Error in archiveOldAnalytics:', error);
      throw error;
    }
  });

/**
 * Generate daily statistics at 4 AM
 * Compute and cache daily stats for dashboard
 */
export const generateDailyStatistics = functions.pubsub
  .schedule('0 4 * * *') // 4 AM daily
  .onRun(async (context) => {
    functions.logger.info('Generating daily statistics...');

    try {
      const stats = await AnalyticsHelper.getSystemStats(1); // Last 1 day

      // Store in a statistics collection for quick dashboard access
      await db.collection('notificationStatistics').doc('daily').set(
        {
          ...stats,
          generatedAt: admin.firestore.FieldValue.serverTimestamp(),
          period: 'daily',
        },
        { merge: true }
      );

      functions.logger.info('Daily statistics generated:', stats);
      return;
    } catch (error) {
      functions.logger.error('Error in generateDailyStatistics:', error);
      throw error;
    }
  });

/**
 * Cleanup invalid tokens weekly
 * Find and remove tokens that haven't been used recently
 */
export const cleanupInvalidTokens = functions.pubsub
  .schedule('0 5 * * 0') // 5 AM every Sunday
  .onRun(async (context) => {
    functions.logger.info('Cleaning up invalid tokens...');

    try {
      // Get all users
      const usersSnapshot = await db
        .collection('users')
        .limit(1000)
        .get();

      let cleanedTokenCount = 0;

      for (const userDoc of usersSnapshot.docs) {
        try {
          const userId = userDoc.id;

          // Get user's tokens
          const tokensSnapshot = await db
            .collection('users')
            .doc(userId)
            .collection('fcmTokens')
            .get();

          for (const tokenDoc of tokensSnapshot.docs) {
            const tokenData = tokenDoc.data();
            const savedAt = (tokenData.savedAt as admin.firestore.Timestamp)?.toDate();

            if (savedAt) {
              const daysSinceSaved =
                (Date.now() - savedAt.getTime()) / (1000 * 60 * 60 * 24);

              // Remove tokens not used in 90 days
              if (daysSinceSaved > 90) {
                await tokenDoc.ref.delete();
                cleanedTokenCount++;
                functions.logger.info(
                  `Removed old token for user ${userId}: ${daysSinceSaved} days old`
                );
              }
            }
          }
        } catch (error) {
          functions.logger.warn(`Error cleaning tokens for user:`, error);
        }
      }

      functions.logger.info(`Cleaned up ${cleanedTokenCount} old tokens`);
      return;
    } catch (error) {
      functions.logger.error('Error in cleanupInvalidTokens:', error);
      throw error;
    }
  });

/**
 * Weekly summary email/notification to admins
 * Send system statistics and health report
 */
export const sendWeeklySummary = functions.pubsub
  .schedule('0 9 * * 1') // 9 AM every Monday
  .onRun(async (context) => {
    functions.logger.info('Generating weekly summary...');

    try {
      const weeklyStats = await AnalyticsHelper.getSystemStats(7);
      const dlqStats = await DeadLetterQueueHelper.getQueueStats();
      const failureAnalysis = await DeadLetterQueueHelper.getFailureAnalysis();

      const summary = {
        period: 'weekly',
        generatedAt: new Date().toISOString(),
        notifications: weeklyStats,
        dlq: dlqStats,
        failureAnalysis,
        trend: await AnalyticsHelper.getDailyTrend(7),
      };

      // Store summary for admin review
      await db
        .collection('notificationStatistics')
        .doc('weekly_' + Date.now())
        .set(summary);

      functions.logger.info('Weekly summary generated:', summary);

      // TODO: Send email to admins with summary
      // sendEmailToAdmins(summary);

      return;
    } catch (error) {
      functions.logger.error('Error in sendWeeklySummary:', error);
      throw error;
    }
  });
