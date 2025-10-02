import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

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
    // This is a heuristic; adjust as needed according to your app’s logic
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
