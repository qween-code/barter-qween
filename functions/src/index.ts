import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

// Import barter functions
import { calculateBarterMatch, getMatchingItemsForCondition } from './barter/matchingAlgorithm';

// Export barter functions
export { calculateBarterMatch, getMatchingItemsForCondition };

async function getUserTokens(userId: string): Promise<string[]> {
  const tokensSnap = await db.collection('users').doc(userId).collection('fcmTokens').get();
  if (tokensSnap.empty) return [];
  return tokensSnap.docs.map((d) => (d.get('token') as string) ?? d.id).filter(Boolean);
}

async function sendMulticast(tokens: string[], notification: admin.messaging.Notification, data?: { [key: string]: string }) {
  if (!tokens || tokens.length === 0) return;
  const payload: admin.messaging.MulticastMessage = { tokens, notification, data };
  const res = await admin.messaging().sendMulticast(payload);
  functions.logger.info('Push sent', { successCount: res.successCount, failureCount: res.failureCount });

  // Clean up invalid tokens
  if (res.failureCount > 0) {
    const failedTokens: string[] = [];
    res.responses.forEach((resp, idx) => {
      if (!resp.success && resp.error) {
        const errorCode = resp.error.code;
        if (errorCode === 'messaging/invalid-registration-token' || errorCode === 'messaging/registration-token-not-registered') {
          failedTokens.push(tokens[idx]);
        }
      }
    });
    // TODO: Remove invalid tokens from Firestore
    if (failedTokens.length > 0) {
      functions.logger.info('Invalid tokens detected', { count: failedTokens.length });
    }
  }
}

// Trigger: when a new message is created, notify other participants
export const onMessageCreated = functions.firestore
  .document('messages/{messageId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const conversationId = data?.conversationId as string | undefined;
    const senderId = data?.senderId as string | undefined;
    const text = data?.text as string | '';

    if (!conversationId || !senderId) return null;

    // Lookup conversation participants
    const convDoc = await db.collection('conversations').doc(conversationId).get();
    if (!convDoc.exists) return null;
    const participants = (convDoc.get('participants') as string[]) || [];
    const recipients = participants.filter((p) => p !== senderId);

    // Collect tokens
    const allTokens: string[] = [];
    for (const uid of recipients) {
      const tokens = await getUserTokens(uid);
      allTokens.push(...tokens);
    }

    await sendMulticast(allTokens, { title: 'New message', body: text }, { type: 'new_message', entityId: conversationId });
    return null;
  });

// Trigger: when a new trade offer is created, notify the receiver
export const onTradeOfferCreated = functions.firestore
  .document('tradeOffers/{tradeId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data) return null;
    const toUserId = data.toUserId as string | undefined;
    const offeredItemTitle = data.offeredItemTitle as string | undefined;

    if (!toUserId) return null;
    const tokens = await getUserTokens(toUserId);
    await sendMulticast(tokens, { title: 'New trade offer', body: offeredItemTitle ?? 'You received a trade offer' }, { type: 'new_trade_offer', entityId: context.params.tradeId });
    return null;
  });

// Trigger: when a trade offer status changes, notify the other party
export const onTradeOfferUpdated = functions.firestore
  .document('tradeOffers/{tradeId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    if (!before || !after) return null;

    const beforeStatus = before.status as string | undefined;
    const afterStatus = after.status as string | undefined;

    if (beforeStatus === afterStatus) return null;

    const fromUserId = after.fromUserId as string | undefined;
    const toUserId = after.toUserId as string | undefined;

    let notifyUser: string | undefined;
    let title = 'Trade updated';
    let body = `Status: ${afterStatus}`;
    let type = `trade_${afterStatus}`;

    // If toUser changed status (accept/reject/cancel), notify fromUser; otherwise notify toUser
    // This is a heuristic; adjust as needed according to your app's logic
    notifyUser = fromUserId ?? toUserId;

    if (afterStatus === 'accepted') { title = 'Trade accepted'; body = 'Your offer was accepted'; }
    if (afterStatus === 'rejected') { title = 'Trade rejected'; body = 'Your offer was rejected'; }
    if (afterStatus === 'cancelled') { title = 'Trade cancelled'; body = 'Offer was cancelled'; }
    if (afterStatus === 'completed') { title = 'Trade completed'; body = 'Trade completed successfully'; }

    if (!notifyUser) return null;
    const tokens = await getUserTokens(notifyUser);
    await sendMulticast(tokens, { title, body }, { type, entityId: context.params.tradeId });
    return null;
  });

// Trigger: when a notification document is created in user's subcollection, send push
export const onNotificationCreated = functions.firestore
  .document('users/{userId}/notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data) return null;

    const userId = context.params.userId;
    const title = data.title as string | 'Notification';
    const body = data.body as string | '';
    const type = data.type as string | undefined;
    const entityId = data.entityId as string | undefined;

    // Build push data payload
    const pushData: { [key: string]: string } = {};
    if (type) pushData.type = type;
    if (entityId) pushData.entityId = entityId;

    const tokens = await getUserTokens(userId);
    await sendMulticast(tokens, { title, body }, pushData);
    return null;
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
