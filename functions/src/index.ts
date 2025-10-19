import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

// Import helpers and services
import { NotificationHelper, NotificationPayload } from './notification/NotificationHelper';

// Import barter functions
import { calculateBarterMatch, getMatchingItemsForCondition } from './barter/matchingAlgorithm';
import { onItemCreated, onItemUpdated } from './barter/itemTriggers';

// Import negotiation functions
import { onCounterOfferCreated, onNegotiationUpdated } from './negotiation/negotiationTriggers';

// Import notification triggers
import {
  onRatingCreated,
  onFollowCreated,
  onCampaignCreated,
  onItemPromoted,
  onWarningIssued,
  onSystemNotificationCreated,
  onCounterOfferReceivedNotification,
} from './notification/notificationTriggers';

// Export barter functions
export { calculateBarterMatch, getMatchingItemsForCondition, onItemCreated, onItemUpdated };

// Export negotiation functions
export { onCounterOfferCreated, onNegotiationUpdated };

// Export notification triggers
export {
  onRatingCreated,
  onFollowCreated,
  onCampaignCreated,
  onItemPromoted,
  onWarningIssued,
  onSystemNotificationCreated,
  onCounterOfferReceivedNotification,
};

// Trigger: when a new message is created, notify other participants
export const onMessageCreated = functions.firestore
  .document('messages/{messageId}')
  .onCreate(async (snap, context) => {
    try {
      const data = snap.data();
      const conversationId = data?.conversationId as string | undefined;
      const senderId = data?.senderId as string | undefined;
      const senderName = data?.senderName as string | 'Kullanıcı';
      const text = data?.text as string | '';

      if (!conversationId || !senderId) return null;

      // Lookup conversation participants
      const convDoc = await db.collection('conversations').doc(conversationId).get();
      if (!convDoc.exists) return null;
      const participants = (convDoc.get('participants') as string[]) || [];
      const recipients = participants.filter((p) => p !== senderId);

      // Send notification to each recipient
      for (const recipientId of recipients) {
        const payload: NotificationPayload = {
          title: `Yeni mesaj: ${senderName}`,
          body: text.substring(0, 100),
          type: 'new_message',
          entityId: conversationId,
          data: {
            conversationId,
            senderId,
          },
        };

        await NotificationHelper.createAndSendNotification(recipientId, payload);
      }

      functions.logger.info(`Message notifications sent to ${recipients.length} recipients`);
      return null;
    } catch (error) {
      functions.logger.error('Error in onMessageCreated trigger:', error);
      return null;
    }
  });

// Trigger: when a new trade offer is created, notify the receiver
export const onTradeOfferCreated = functions.firestore
  .document('tradeOffers/{tradeId}')
  .onCreate(async (snap, context) => {
    try {
      const data = snap.data();
      if (!data) return null;

      const toUserId = data.toUserId as string | undefined;
      const fromUserId = data.fromUserId as string | undefined;
      const offeredItemTitle = data.offeredItemTitle as string | undefined;
      const requestedItemTitle = data.requestedItemTitle as string | undefined;

      if (!toUserId) return null;

      // Get sender name
      const senderDoc = await db.collection('users').doc(fromUserId).get();
      const senderName = senderDoc.data()?.displayName || 'Bir kullanıcı';

      // Check for duplicate
      const isDuplicate = await NotificationHelper.isDuplicateNotification(
        toUserId,
        'new_trade_offer',
        context.params.tradeId,
        5
      );

      if (isDuplicate) {
        functions.logger.info(`Duplicate trade offer notification for user ${toUserId}`);
        return null;
      }

      const payload: NotificationPayload = {
        title: 'Yeni ticari teklif',
        body: `${senderName} sana "${offeredItemTitle}" ile ticari tekliftte bulundu`,
        type: 'new_trade_offer',
        entityId: context.params.tradeId,
        data: {
          tradeId: context.params.tradeId,
          fromUserId: fromUserId || '',
          offeredItem: offeredItemTitle || '',
          requestedItem: requestedItemTitle || '',
        },
      };

      await NotificationHelper.createAndSendNotification(toUserId, payload);
      functions.logger.info(`Trade offer notification sent to user ${toUserId}`);

      return null;
    } catch (error) {
      functions.logger.error('Error in onTradeOfferCreated trigger:', error);
      return null;
    }
  });

// Trigger: when a trade offer status changes, notify the other party
export const onTradeOfferUpdated = functions.firestore
  .document('tradeOffers/{tradeId}')
  .onUpdate(async (change, context) => {
    try {
      const before = change.before.data();
      const after = change.after.data();
      if (!before || !after) return null;

      const beforeStatus = before.status as string | undefined;
      const afterStatus = after.status as string | undefined;

      if (beforeStatus === afterStatus) return null;

      const fromUserId = after.fromUserId as string | undefined;
      const toUserId = after.toUserId as string | undefined;

      let notifyUserId: string | undefined;
      let title = 'Ticari işlem güncellendi';
      let body = `Durum: ${afterStatus}`;
      let type = `trade_${afterStatus}`;

      if (afterStatus === 'accepted') {
        title = 'Ticari işlem kabul edildi';
        body = 'Teklifin kabul edildi';
        notifyUserId = fromUserId;
      } else if (afterStatus === 'rejected') {
        title = 'Ticari işlem reddedildi';
        body = 'Teklifin reddedildi';
        notifyUserId = fromUserId;
      } else if (afterStatus === 'cancelled') {
        title = 'Ticari işlem iptal edildi';
        body = 'Teklif iptal edildi';
        notifyUserId = toUserId;
      } else if (afterStatus === 'completed') {
        title = 'Ticari işlem tamamlandı';
        body = 'İşlem başarıyla tamamlandı';
        notifyUserId = fromUserId ?? toUserId;
      }

      if (!notifyUserId) return null;

      // Check for duplicate
      const isDuplicate = await NotificationHelper.isDuplicateNotification(
        notifyUserId,
        type,
        context.params.tradeId,
        5
      );

      if (isDuplicate) {
        functions.logger.info(`Duplicate trade update notification for user ${notifyUserId}`);
        return null;
      }

      const payload: NotificationPayload = {
        title,
        body,
        type,
        entityId: context.params.tradeId,
        data: {
          tradeId: context.params.tradeId,
          status: afterStatus || '',
        },
      };

      await NotificationHelper.createAndSendNotification(notifyUserId, payload);
      functions.logger.info(`Trade update notification sent to user ${notifyUserId}`);

      return null;
    } catch (error) {
      functions.logger.error('Error in onTradeOfferUpdated trigger:', error);
      return null;
    }
  });

// Trigger: when a notification document is created, send push notification
// NOTE: This is handled by NotificationHelper.createAndSendNotification()
// But we keep this as a fallback/secondary trigger for notifications created directly
export const onNotificationCreated = functions.firestore
  .document('users/{userId}/notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    try {
      const data = snap.data();
      if (!data) return null;

      const userId = context.params.userId;
      const title = data.title as string | 'Bildirim';
      const body = data.body as string | '';
      const type = data.type as string | undefined;
      const entityId = data.entityId as string | undefined;

      // Check if notification was already processed (to avoid duplicate sends)
      const processed = data.processed as boolean | undefined;
      if (processed) {
        return null;
      }

      // Build notification payload
      const tokens = await NotificationHelper.getUserTokens(userId);

      if (tokens.length === 0) {
        functions.logger.warn(`No tokens found for user ${userId}`);
        return null;
      }

      const { invalidTokens } = await NotificationHelper.sendMulticastWithRetry(
        tokens,
        { title, body },
        {
          type: type || 'generic',
          entityId: entityId || '',
        }
      );

      // Clean up invalid tokens
      if (invalidTokens.length > 0) {
        await NotificationHelper.cleanupInvalidTokens(userId, invalidTokens);
      }

      // Mark as processed
      await snap.ref.update({ processed: true });

      functions.logger.info(`Push notification sent for notification ${context.params.notificationId}`);
      return null;
    } catch (error) {
      functions.logger.error('Error in onNotificationCreated trigger:', error);
      return null;
    }
  });

// Trigger: Update item view count when item_views document is created
export const onItemViewCreated = functions.firestore
  .document('item_views/{viewId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data) return null;

    const itemId = data.itemId as string | undefined;
    if (!itemId) return null;

    try {
      // Increment viewCount on the item
      const itemRef = db.collection('items').doc(itemId);
      await itemRef.update({
        viewCount: admin.firestore.FieldValue.increment(1),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.info('Item view count incremented', { itemId });
    } catch (error) {
      functions.logger.error('Error incrementing view count', { itemId, error });
    }

    return null;
  });

// Trigger: Update user stats when item is favorited
export const onItemFavorited = functions.firestore
  .document('favorites/{favoriteId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data) return null;

    const itemId = data.itemId as string | undefined;
    if (!itemId) return null;

    try {
      // Get item to find owner
      const itemDoc = await db.collection('items').doc(itemId).get();
      if (!itemDoc.exists) return null;

      const ownerId = itemDoc.get('ownerId') as string | undefined;
      if (!ownerId) return null;

      // Increment favoriteCount on item
      await db.collection('items').doc(itemId).update({
        favoriteCount: admin.firestore.FieldValue.increment(1),
      });

      // Increment seller's totalFavorites
      await db.collection('users').doc(ownerId).update({
        totalFavorites: admin.firestore.FieldValue.increment(1),
      });

      functions.logger.info('Item favorited', { itemId, ownerId });
    } catch (error) {
      functions.logger.error('Error updating favorite stats', { itemId, error });
    }

    return null;
  });

// Trigger: Update user stats when item is unfavorited
export const onItemUnfavorited = functions.firestore
  .document('favorites/{favoriteId}')
  .onDelete(async (snap, context) => {
    const data = snap.data();
    if (!data) return null;

    const itemId = data.itemId as string | undefined;
    if (!itemId) return null;

    try {
      // Get item to find owner
      const itemDoc = await db.collection('items').doc(itemId).get();
      if (!itemDoc.exists) return null;

      const ownerId = itemDoc.get('ownerId') as string | undefined;
      if (!ownerId) return null;

      // Decrement favoriteCount on item
      await db.collection('items').doc(itemId).update({
        favoriteCount: admin.firestore.FieldValue.increment(-1),
      });

      // Decrement seller's totalFavorites
      await db.collection('users').doc(ownerId).update({
        totalFavorites: admin.firestore.FieldValue.increment(-1),
      });

      functions.logger.info('Item unfavorited', { itemId, ownerId });
    } catch (error) {
      functions.logger.error('Error updating unfavorite stats', { itemId, error });
    }

    return null;
  });

// Trigger: Update seller stats when trade is completed
export const onTradeCompleted = functions.firestore
  .document('tradeOffers/{tradeId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    if (!before || !after) return null;

    const beforeStatus = before.status as string | undefined;
    const afterStatus = after.status as string | undefined;

    // Only trigger when status changes to 'completed'
    if (beforeStatus !== 'completed' && afterStatus === 'completed') {
      const fromUserId = after.fromUserId as string | undefined;
      const toUserId = after.toUserId as string | undefined;

      if (!fromUserId || !toUserId) return null;

      try {
        // Increment totalTrades for both users
        await db.collection('users').doc(fromUserId).update({
          totalTrades: admin.firestore.FieldValue.increment(1),
        });

        await db.collection('users').doc(toUserId).update({
          totalTrades: admin.firestore.FieldValue.increment(1),
        });

        functions.logger.info('Trade completed - stats updated', { fromUserId, toUserId });
      } catch (error) {
        functions.logger.error('Error updating trade stats', { fromUserId, toUserId, error });
      }
    }

    return null;
  });
