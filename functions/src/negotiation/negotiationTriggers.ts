import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

// Trigger: when a counter offer is created, notify the other party
export const onCounterOfferCreated = functions.firestore
  .document('counter_offers/{counterOfferId}')
  .onCreate(async (snap, context) => {
    const counterOfferData = snap.data();
    if (!counterOfferData) return;

    const negotiationId = counterOfferData.negotiationId;
    const offererId = counterOfferData.offererId;
    const targetUserId = counterOfferData.targetUserId;

    functions.logger.info(`Counter offer created for negotiation ${negotiationId}`);

    try {
      // Get negotiation details
      const negotiationSnap = await db.collection('negotiations').doc(negotiationId).get();
      if (!negotiationSnap.exists) {
        functions.logger.error(`Negotiation ${negotiationId} not found`);
        return;
      }

      const negotiationData = negotiationSnap.data();
      const sourceItemId = negotiationData?.sourceItemId;
      const targetItemId = negotiationData?.targetItemId;

      // Get user tokens for notification
      const tokens = await getUserTokens(targetUserId);
      if (tokens.length === 0) {
        functions.logger.info(`No FCM tokens found for user ${targetUserId}`);
        return;
      }

      // Get offerer name
      const offererSnap = await db.collection('users').doc(offererId).get();
      const offererName = offererSnap.data()?.displayName || 'Someone';

      // Get item details
      const sourceItemSnap = await db.collection('items').doc(sourceItemId).get();
      const sourceItemTitle = sourceItemSnap.data()?.title || 'Item';

      // Prepare notification
      const notification: admin.messaging.Notification = {
        title: 'New Counter Offer',
        body: `${offererName} sent a counter offer for ${sourceItemTitle}`,
      };

      const data = {
        type: 'counter_offer',
        negotiationId: negotiationId,
        counterOfferId: snap.id,
        sourceItemId: sourceItemId,
        targetItemId: targetItemId,
        offererId: offererId,
      };

      // Send notification
      await sendMulticast(tokens, notification, data);

      // Create notification document
      await db.collection('notifications').add({
        userId: targetUserId,
        type: 'counter_offer',
        title: notification.title,
        body: notification.body,
        data: data,
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.info(`Counter offer notification sent to user ${targetUserId}`);
    } catch (error) {
      functions.logger.error('Error sending counter offer notification:', error);
    }
  });

// Trigger: when negotiation status is updated, notify participants
export const onNegotiationUpdated = functions.firestore
  .document('negotiations/{negotiationId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    const negotiationId = context.params.negotiationId;

    if (!beforeData || !afterData) return;

    const beforeStatus = beforeData.status;
    const afterStatus = afterData.status;

    // Only notify on status changes
    if (beforeStatus === afterStatus) return;

    functions.logger.info(`Negotiation ${negotiationId} status changed from ${beforeStatus} to ${afterStatus}`);

    try {
      const initiatorId = afterData.initiatorId;
      const receiverId = afterData.receiverId;
      const sourceItemId = afterData.sourceItemId;
      const targetItemId = afterData.targetItemId;

      // Determine who to notify based on status change
      let targetUserId: string;
      let notificationTitle: string;
      let notificationBody: string;

      switch (afterStatus) {
        case 'accepted':
          targetUserId = initiatorId;
          notificationTitle = 'Negotiation Accepted!';
          notificationBody = 'Your negotiation has been accepted';
          break;
        case 'rejected':
          targetUserId = initiatorId;
          notificationTitle = 'Negotiation Rejected';
          notificationBody = 'Your negotiation was rejected';
          break;
        case 'completed':
          // Notify both parties
          await notifyBothParties(negotiationId, 'completed', 'Negotiation Completed', 'Your negotiation is now complete');
          return;
        default:
          return;
      }

      // Get user tokens
      const tokens = await getUserTokens(targetUserId);
      if (tokens.length === 0) {
        functions.logger.info(`No FCM tokens found for user ${targetUserId}`);
        return;
      }

      // Get item details
      const sourceItemSnap = await db.collection('items').doc(sourceItemId).get();
      const sourceItemTitle = sourceItemSnap.data()?.title || 'Item';

      // Prepare notification
      const notification: admin.messaging.Notification = {
        title: notificationTitle,
        body: `${notificationBody} for ${sourceItemTitle}`,
      };

      const data = {
        type: 'negotiation_update',
        negotiationId: negotiationId,
        status: afterStatus,
        sourceItemId: sourceItemId,
        targetItemId: targetItemId,
      };

      // Send notification
      await sendMulticast(tokens, notification, data);

      // Create notification document
      await db.collection('notifications').add({
        userId: targetUserId,
        type: 'negotiation_update',
        title: notification.title,
        body: notification.body,
        data: data,
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.info(`Negotiation update notification sent to user ${targetUserId}`);
    } catch (error) {
      functions.logger.error('Error sending negotiation update notification:', error);
    }
  });

// Helper function to notify both parties
async function notifyBothParties(
  negotiationId: string,
  status: string,
  title: string,
  body: string
) {
  try {
    const negotiationSnap = await db.collection('negotiations').doc(negotiationId).get();
    if (!negotiationSnap.exists) return;

    const negotiationData = negotiationSnap.data();
    const initiatorId = negotiationData?.initiatorId;
    const receiverId = negotiationData?.receiverId;
    const sourceItemId = negotiationData?.sourceItemId;
    const targetItemId = negotiationData?.targetItemId;

    // Get item details
    const sourceItemSnap = await db.collection('items').doc(sourceItemId).get();
    const sourceItemTitle = sourceItemSnap.data()?.title || 'Item';

    const data = {
      type: 'negotiation_update',
      negotiationId: negotiationId,
      status: status,
      sourceItemId: sourceItemId,
      targetItemId: targetItemId,
    };

    // Notify initiator
    const initiatorTokens = await getUserTokens(initiatorId);
    if (initiatorTokens.length > 0) {
      const initiatorNotification: admin.messaging.Notification = {
        title: title,
        body: `${body} for ${sourceItemTitle}`,
      };
      await sendMulticast(initiatorTokens, initiatorNotification, data);
      
      await db.collection('notifications').add({
        userId: initiatorId,
        type: 'negotiation_update',
        title: initiatorNotification.title,
        body: initiatorNotification.body,
        data: data,
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // Notify receiver
    const receiverTokens = await getUserTokens(receiverId);
    if (receiverTokens.length > 0) {
      const receiverNotification: admin.messaging.Notification = {
        title: title,
        body: `${body} for ${sourceItemTitle}`,
      };
      await sendMulticast(receiverTokens, receiverNotification, data);
      
      await db.collection('notifications').add({
        userId: receiverId,
        type: 'negotiation_update',
        title: receiverNotification.title,
        body: receiverNotification.body,
        data: data,
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    functions.logger.info(`Both parties notified for negotiation ${negotiationId}`);
  } catch (error) {
    functions.logger.error('Error notifying both parties:', error);
  }
}

// Helper function to get user FCM tokens
async function getUserTokens(userId: string): Promise<string[]> {
  const tokensSnap = await db.collection('users').doc(userId).collection('fcmTokens').get();
  if (tokensSnap.empty) return [];
  return tokensSnap.docs.map((d) => (d.get('token') as string) ?? d.id).filter(Boolean);
}

// Helper function to send multicast notification
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
    
    if (failedTokens.length > 0) {
      functions.logger.info('Invalid tokens detected', { count: failedTokens.length });
      // TODO: Remove invalid tokens from Firestore
    }
  }
}
