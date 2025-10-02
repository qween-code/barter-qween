import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

// Trigger: when a new message is created, log intent to send push
export const onMessageCreated = functions.firestore
  .document('messages/{messageId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const conversationId = data?.conversationId as string | undefined;
    const senderId = data?.senderId as string | undefined;
    const text = data?.text as string | undefined;

    functions.logger.info('New message', { conversationId, senderId, text });

    // TODO: Lookup participants by conversationId and send push to other users via FCM tokens
    // Example:
    // const tokens = await getUserTokens(otherUserId);
    // await admin.messaging().sendMulticast({ tokens, notification: { title: 'New message', body: text ?? '' }, data: { type: 'new_message', entityId: conversationId ?? '' } });

    return null;
  });

// Trigger: when a trade offer status changes, log intent to send push
export const onTradeOfferUpdated = functions.firestore
  .document('tradeOffers/{tradeId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (!before || !after) return null;

    const beforeStatus = before.status as string | undefined;
    const afterStatus = after.status as string | undefined;

    if (beforeStatus !== afterStatus) {
      functions.logger.info('Trade status changed', { tradeId: context.params.tradeId, beforeStatus, afterStatus });
      // TODO: Determine recipients (fromUserId/toUserId) and send push via FCM tokens
      // await sendPushToUser(after.toUserId, { title: 'Trade updated', body: `Status: ${afterStatus}`, data: { type: `trade_${afterStatus}`, entityId: context.params.tradeId } });
    }

    return null;
  });
