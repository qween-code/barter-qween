import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { NotificationHelper, NotificationPayload } from './NotificationHelper';

const db = admin.firestore();

/**
 * TRIGGER: When a new rating is created
 * Notify the user who received the rating
 */
export const onRatingCreated = functions.firestore
  .document('ratings/{ratingId}')
  .onCreate(async (snap, context) => {
    try {
      const ratingData = snap.data();
      const ratedUserId = ratingData?.ratedUserId as string;
      const ratingUserId = ratingData?.ratingUserId as string;
      const rating = ratingData?.rating as number;
      const comment = ratingData?.comment as string;

      if (!ratedUserId || !ratingUserId) {
        functions.logger.warn('Invalid rating data: missing userId fields');
        return null;
      }

      // Get rater's name
      const raterDoc = await db.collection('users').doc(ratingUserId).get();
      const raterName = raterDoc.data()?.displayName || 'Bir kullanıcı';

      // Check for duplicate notification (deduplication)
      const isDuplicate = await NotificationHelper.isDuplicateNotification(
        ratedUserId,
        'new_rating',
        context.params.ratingId,
        5 // 5 minute window
      );

      if (isDuplicate) {
        functions.logger.info(`Duplicate rating notification for user ${ratedUserId}`);
        return null;
      }

      const payload: NotificationPayload = {
        title: `Yeni değerlendirme - ${rating}★`,
        body: `${raterName} seni ${rating} yıldızla değerlendirdi: "${comment?.substring(0, 50)}"`,
        type: 'new_rating',
        entityId: ratingData?.tradeId || context.params.ratingId,
        data: {
          ratingId: context.params.ratingId,
          ratingUserId,
          tradeId: ratingData?.tradeId || '',
        },
      };

      await NotificationHelper.createAndSendNotification(ratedUserId, payload);
      functions.logger.info(`Rating notification sent to user ${ratedUserId}`);

      return null;
    } catch (error) {
      functions.logger.error('Error in onRatingCreated trigger:', error);
      return null;
    }
  });

/**
 * TRIGGER: When a user is followed
 * Notify the user who received the follow
 */
export const onFollowCreated = functions.firestore
  .document('users/{userId}/followers/{followerId}')
  .onCreate(async (snap, context) => {
    try {
      const followedUserId = context.params.userId;
      const followerUserId = context.params.followerId;

      // Get follower's name
      const followerDoc = await db.collection('users').doc(followerUserId).get();
      const followerName = followerDoc.data()?.displayName || 'Bir kullanıcı';

      // Check for duplicate notification
      const isDuplicate = await NotificationHelper.isDuplicateNotification(
        followedUserId,
        'new_follow',
        followerUserId,
        10 // 10 minute window
      );

      if (isDuplicate) {
        functions.logger.info(
          `Duplicate follow notification for user ${followedUserId} from ${followerUserId}`
        );
        return null;
      }

      const payload: NotificationPayload = {
        title: 'Yeni takipçi',
        body: `${followerName} seni takip etmeye başladı`,
        type: 'new_follow',
        entityId: followerUserId,
        data: {
          followerUserId,
        },
      };

      await NotificationHelper.createAndSendNotification(followedUserId, payload);
      functions.logger.info(`Follow notification sent to user ${followedUserId}`);

      return null;
    } catch (error) {
      functions.logger.error('Error in onFollowCreated trigger:', error);
      return null;
    }
  });

/**
 * TRIGGER: When a campaign is created
 * Notify all eligible users (async)
 */
export const onCampaignCreated = functions.firestore
  .document('campaigns/{campaignId}')
  .onCreate(async (snap, context) => {
    try {
      const campaignData = snap.data();
      const campaignId = context.params.campaignId;
      const title = campaignData?.title as string;
      const description = campaignData?.description as string;
      const targetCategories = campaignData?.targetCategories as string[];
      const minTrustScore = campaignData?.minTrustScore as number || 0;

      functions.logger.info(`Processing new campaign ${campaignId}`);

      // Find eligible users
      let query = db.collection('users');

      if (minTrustScore > 0) {
        query = query.where('trustScore', '>=', minTrustScore) as any;
      }

      const usersSnapshot = await query.limit(1000).get();

      let notificationCount = 0;
      for (const userDoc of usersSnapshot.docs) {
        const userId = userDoc.id;

        // Check campaign eligibility
        if (targetCategories && targetCategories.length > 0) {
          const userPreferences = userDoc.data()?.categoryPreferences || [];
          const isEligible = targetCategories.some((cat) =>
            userPreferences.includes(cat)
          );

          if (!isEligible) {
            continue;
          }
        }

        // Check for duplicate
        const isDuplicate = await NotificationHelper.isDuplicateNotification(
          userId,
          'campaign_notification',
          campaignId,
          60 // 60 minute window
        );

        if (isDuplicate) {
          continue;
        }

        const payload: NotificationPayload = {
          title: `Yeni kampanya: ${title}`,
          body: description?.substring(0, 100) || '',
          type: 'campaign_notification',
          entityId: campaignId,
          data: {
            campaignId,
          },
        };

        await NotificationHelper.createAndSendNotification(userId, payload);
        notificationCount++;
      }

      functions.logger.info(
        `Campaign notifications sent to ${notificationCount} users for campaign ${campaignId}`
      );

      return null;
    } catch (error) {
      functions.logger.error('Error in onCampaignCreated trigger:', error);
      return null;
    }
  });

/**
 * TRIGGER: When an item is promoted/featured
 * Notify the item owner
 */
export const onItemPromoted = functions.firestore
  .document('promotions/{promotionId}')
  .onCreate(async (snap, context) => {
    try {
      const promotionData = snap.data();
      const itemId = promotionData?.itemId as string;
      const promotionType = promotionData?.type as string; // 'featured', 'sponsored', etc.

      if (!itemId) {
        functions.logger.warn('Invalid promotion data: missing itemId');
        return null;
      }

      // Get item details
      const itemDoc = await db.collection('items').doc(itemId).get();
      if (!itemDoc.exists) {
        functions.logger.warn(`Item not found: ${itemId}`);
        return null;
      }

      const itemData = itemDoc.data();
      const ownerId = itemData?.ownerId as string;
      const itemTitle = itemData?.title as string;

      if (!ownerId) {
        functions.logger.warn(`Item owner not found for item ${itemId}`);
        return null;
      }

      const typeLabel =
        promotionType === 'featured'
          ? 'Ön Plana Çıktı'
          : promotionType === 'sponsored'
            ? 'Sponsorlu'
            : 'Promosyon';

      const payload: NotificationPayload = {
        title: `${itemTitle} ${typeLabel}`,
        body: `Ürünün "${itemTitle}" daha çok görünürlüğe sahip olacak`,
        type: 'promotion_notification',
        entityId: itemId,
        data: {
          itemId,
          promotionType,
        },
      };

      await NotificationHelper.createAndSendNotification(ownerId, payload);
      functions.logger.info(`Promotion notification sent to user ${ownerId}`);

      return null;
    } catch (error) {
      functions.logger.error('Error in onItemPromoted trigger:', error);
      return null;
    }
  });

/**
 * TRIGGER: When a warning is issued to a user
 * Notify the user
 */
export const onWarningIssued = functions.firestore
  .document('warnings/{warningId}')
  .onCreate(async (snap, context) => {
    try {
      const warningData = snap.data();
      const userId = warningData?.userId as string;
      const reason = warningData?.reason as string;
      const severity = warningData?.severity as string; // 'warning', 'caution', 'alert'

      if (!userId) {
        functions.logger.warn('Invalid warning data: missing userId');
        return null;
      }

      const severityLabel =
        severity === 'alert'
          ? '⚠️ UYARI'
          : severity === 'caution'
            ? 'Dikkat'
            : 'Bilgilendirme';

      const payload: NotificationPayload = {
        title: `${severityLabel}: Hesap Uyarısı`,
        body: reason || 'Hesabınız hakkında bir uyarı alınız',
        type: 'warning_notification',
        entityId: context.params.warningId,
        data: {
          warningId: context.params.warningId,
          severity,
        },
      };

      await NotificationHelper.createAndSendNotification(userId, payload);
      functions.logger.info(`Warning notification sent to user ${userId}`);

      return null;
    } catch (error) {
      functions.logger.error('Error in onWarningIssued trigger:', error);
      return null;
    }
  });

/**
 * TRIGGER: System notification (admin broadcast)
 * Notify specific or all users
 */
export const onSystemNotificationCreated = functions.firestore
  .document('system_notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    try {
      const notifData = snap.data();
      const notifId = context.params.notificationId;
      const title = notifData?.title as string;
      const body = notifData?.body as string;
      const targetUsers = notifData?.targetUsers as string[]; // null = all users
      const targetSegments = notifData?.targetSegments as string[]; // ['premium', 'active']

      functions.logger.info(`Processing system notification ${notifId}`);

      let usersToNotify: Set<string> = new Set();

      if (!targetUsers || targetUsers.length === 0) {
        // No specific users - broadcast to all
        const allUsersSnapshot = await db.collection('users').limit(10000).get();
        allUsersSnapshot.docs.forEach((doc) => {
          usersToNotify.add(doc.id);
        });
      } else {
        // Specific users
        targetUsers.forEach((uid) => usersToNotify.add(uid));
      }

      // Filter by segments if specified
      if (targetSegments && targetSegments.length > 0) {
        const filteredUsers: Set<string> = new Set();

        for (const userId of usersToNotify) {
          const userDoc = await db.collection('users').doc(userId).get();
          const userSegments = userDoc.data()?.segments || [];

          const isInSegment = targetSegments.some((seg) => userSegments.includes(seg));

          if (isInSegment) {
            filteredUsers.add(userId);
          }
        }

        usersToNotify = filteredUsers;
      }

      let notificationCount = 0;
      for (const userId of usersToNotify) {
        const payload: NotificationPayload = {
          title,
          body,
          type: 'system_notification',
          entityId: notifId,
          data: {
            notificationId: notifId,
          },
        };

        await NotificationHelper.createAndSendNotification(userId, payload);
        notificationCount++;
      }

      functions.logger.info(
        `System notification sent to ${notificationCount} users`
      );

      return null;
    } catch (error) {
      functions.logger.error('Error in onSystemNotificationCreated trigger:', error);
      return null;
    }
  });

/**
 * TRIGGER: When a counter offer is received (enhancement to existing)
 * This is an explicit trigger for negotiation/counter offer
 */
export const onCounterOfferReceivedNotification = functions.firestore
  .document('counterOffers/{offerId}')
  .onCreate(async (snap, context) => {
    try {
      const counterOfferData = snap.data();
      const receiverId = counterOfferData?.recipientUserId as string;
      const senderId = counterOfferData?.senderUserId as string;
      const tradeId = counterOfferData?.tradeId as string;
      const offeredPrice = counterOfferData?.offeredPrice as number;

      if (!receiverId) {
        functions.logger.warn('Invalid counter offer data: missing recipientUserId');
        return null;
      }

      // Get sender's name
      const senderDoc = await db.collection('users').doc(senderId).get();
      const senderName = senderDoc.data()?.displayName || 'Bir kullanıcı';

      // Check for duplicate
      const isDuplicate = await NotificationHelper.isDuplicateNotification(
        receiverId,
        'counter_offer_received',
        context.params.offerId,
        5
      );

      if (isDuplicate) {
        functions.logger.info(
          `Duplicate counter offer notification for user ${receiverId}`
        );
        return null;
      }

      const payload: NotificationPayload = {
        title: 'Yeni karşı teklif',
        body: `${senderName} sana ₺${offeredPrice} karşı teklif yaptı`,
        type: 'counter_offer_received',
        entityId: tradeId,
        data: {
          offerId: context.params.offerId,
          tradeId,
          senderId,
        },
      };

      await NotificationHelper.createAndSendNotification(receiverId, payload);
      functions.logger.info(
        `Counter offer notification sent to user ${receiverId}`
      );

      return null;
    } catch (error) {
      functions.logger.error('Error in onCounterOfferReceivedNotification trigger:', error);
      return null;
    }
  });
