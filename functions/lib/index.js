"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.onTradeCompleted = exports.onItemUnfavorited = exports.onItemFavorited = exports.onItemViewCreated = exports.onNotificationCreated = exports.onTradeOfferUpdated = exports.onTradeOfferCreated = exports.onMessageCreated = exports.onNegotiationUpdated = exports.onCounterOfferCreated = exports.onItemUpdated = exports.onItemCreated = exports.getMatchingItemsForCondition = exports.calculateBarterMatch = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
admin.initializeApp();
const db = admin.firestore();
// Import barter functions
const matchingAlgorithm_1 = require("./barter/matchingAlgorithm");
Object.defineProperty(exports, "calculateBarterMatch", { enumerable: true, get: function () { return matchingAlgorithm_1.calculateBarterMatch; } });
Object.defineProperty(exports, "getMatchingItemsForCondition", { enumerable: true, get: function () { return matchingAlgorithm_1.getMatchingItemsForCondition; } });
const itemTriggers_1 = require("./barter/itemTriggers");
Object.defineProperty(exports, "onItemCreated", { enumerable: true, get: function () { return itemTriggers_1.onItemCreated; } });
Object.defineProperty(exports, "onItemUpdated", { enumerable: true, get: function () { return itemTriggers_1.onItemUpdated; } });
// Import negotiation functions
const negotiationTriggers_1 = require("./negotiation/negotiationTriggers");
Object.defineProperty(exports, "onCounterOfferCreated", { enumerable: true, get: function () { return negotiationTriggers_1.onCounterOfferCreated; } });
Object.defineProperty(exports, "onNegotiationUpdated", { enumerable: true, get: function () { return negotiationTriggers_1.onNegotiationUpdated; } });
async function getUserTokens(userId) {
    const tokensSnap = await db.collection('users').doc(userId).collection('fcmTokens').get();
    if (tokensSnap.empty)
        return [];
    return tokensSnap.docs.map((d) => d.get('token') ?? d.id).filter(Boolean);
}
async function sendMulticast(tokens, notification, data) {
    if (!tokens || tokens.length === 0)
        return;
    const payload = { tokens, notification, data };
    const res = await admin.messaging().sendMulticast(payload);
    functions.logger.info('Push sent', { successCount: res.successCount, failureCount: res.failureCount });
    // Clean up invalid tokens
    if (res.failureCount > 0) {
        const failedTokens = [];
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
exports.onMessageCreated = functions.firestore
    .document('messages/{messageId}')
    .onCreate(async (snap, context) => {
    const data = snap.data();
    const conversationId = data?.conversationId;
    const senderId = data?.senderId;
    const text = data?.text;
    if (!conversationId || !senderId)
        return null;
    // Lookup conversation participants
    const convDoc = await db.collection('conversations').doc(conversationId).get();
    if (!convDoc.exists)
        return null;
    const participants = convDoc.get('participants') || [];
    const recipients = participants.filter((p) => p !== senderId);
    // Collect tokens
    const allTokens = [];
    for (const uid of recipients) {
        const tokens = await getUserTokens(uid);
        allTokens.push(...tokens);
    }
    await sendMulticast(allTokens, { title: 'New message', body: text }, { type: 'new_message', entityId: conversationId });
    return null;
});
// Trigger: when a new trade offer is created, notify the receiver
exports.onTradeOfferCreated = functions.firestore
    .document('tradeOffers/{tradeId}')
    .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data)
        return null;
    const toUserId = data.toUserId;
    const offeredItemTitle = data.offeredItemTitle;
    if (!toUserId)
        return null;
    const tokens = await getUserTokens(toUserId);
    await sendMulticast(tokens, { title: 'New trade offer', body: offeredItemTitle ?? 'You received a trade offer' }, { type: 'new_trade_offer', entityId: context.params.tradeId });
    return null;
});
// Trigger: when a trade offer status changes, notify the other party
exports.onTradeOfferUpdated = functions.firestore
    .document('tradeOffers/{tradeId}')
    .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    if (!before || !after)
        return null;
    const beforeStatus = before.status;
    const afterStatus = after.status;
    if (beforeStatus === afterStatus)
        return null;
    const fromUserId = after.fromUserId;
    const toUserId = after.toUserId;
    let notifyUser;
    let title = 'Trade updated';
    let body = `Status: ${afterStatus}`;
    let type = `trade_${afterStatus}`;
    // If toUser changed status (accept/reject/cancel), notify fromUser; otherwise notify toUser
    // This is a heuristic; adjust as needed according to your app's logic
    notifyUser = fromUserId ?? toUserId;
    if (afterStatus === 'accepted') {
        title = 'Trade accepted';
        body = 'Your offer was accepted';
    }
    if (afterStatus === 'rejected') {
        title = 'Trade rejected';
        body = 'Your offer was rejected';
    }
    if (afterStatus === 'cancelled') {
        title = 'Trade cancelled';
        body = 'Offer was cancelled';
    }
    if (afterStatus === 'completed') {
        title = 'Trade completed';
        body = 'Trade completed successfully';
    }
    if (!notifyUser)
        return null;
    const tokens = await getUserTokens(notifyUser);
    await sendMulticast(tokens, { title, body }, { type, entityId: context.params.tradeId });
    return null;
});
// Trigger: when a notification document is created in user's subcollection, send push
exports.onNotificationCreated = functions.firestore
    .document('users/{userId}/notifications/{notificationId}')
    .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data)
        return null;
    const userId = context.params.userId;
    const title = data.title;
    const body = data.body;
    const type = data.type;
    const entityId = data.entityId;
    // Build push data payload
    const pushData = {};
    if (type)
        pushData.type = type;
    if (entityId)
        pushData.entityId = entityId;
    const tokens = await getUserTokens(userId);
    await sendMulticast(tokens, { title, body }, pushData);
    return null;
});
// Trigger: Update item view count when item_views document is created
exports.onItemViewCreated = functions.firestore
    .document('item_views/{viewId}')
    .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data)
        return null;
    const itemId = data.itemId;
    if (!itemId)
        return null;
    try {
        // Increment viewCount on the item
        const itemRef = db.collection('items').doc(itemId);
        await itemRef.update({
            viewCount: admin.firestore.FieldValue.increment(1),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        functions.logger.info('Item view count incremented', { itemId });
    }
    catch (error) {
        functions.logger.error('Error incrementing view count', { itemId, error });
    }
    return null;
});
// Trigger: Update user stats when item is favorited
exports.onItemFavorited = functions.firestore
    .document('favorites/{favoriteId}')
    .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data)
        return null;
    const itemId = data.itemId;
    if (!itemId)
        return null;
    try {
        // Get item to find owner
        const itemDoc = await db.collection('items').doc(itemId).get();
        if (!itemDoc.exists)
            return null;
        const ownerId = itemDoc.get('ownerId');
        if (!ownerId)
            return null;
        // Increment favoriteCount on item
        await db.collection('items').doc(itemId).update({
            favoriteCount: admin.firestore.FieldValue.increment(1),
        });
        // Increment seller's totalFavorites
        await db.collection('users').doc(ownerId).update({
            totalFavorites: admin.firestore.FieldValue.increment(1),
        });
        functions.logger.info('Item favorited', { itemId, ownerId });
    }
    catch (error) {
        functions.logger.error('Error updating favorite stats', { itemId, error });
    }
    return null;
});
// Trigger: Update user stats when item is unfavorited
exports.onItemUnfavorited = functions.firestore
    .document('favorites/{favoriteId}')
    .onDelete(async (snap, context) => {
    const data = snap.data();
    if (!data)
        return null;
    const itemId = data.itemId;
    if (!itemId)
        return null;
    try {
        // Get item to find owner
        const itemDoc = await db.collection('items').doc(itemId).get();
        if (!itemDoc.exists)
            return null;
        const ownerId = itemDoc.get('ownerId');
        if (!ownerId)
            return null;
        // Decrement favoriteCount on item
        await db.collection('items').doc(itemId).update({
            favoriteCount: admin.firestore.FieldValue.increment(-1),
        });
        // Decrement seller's totalFavorites
        await db.collection('users').doc(ownerId).update({
            totalFavorites: admin.firestore.FieldValue.increment(-1),
        });
        functions.logger.info('Item unfavorited', { itemId, ownerId });
    }
    catch (error) {
        functions.logger.error('Error updating unfavorite stats', { itemId, error });
    }
    return null;
});
// Trigger: Update seller stats when trade is completed
exports.onTradeCompleted = functions.firestore
    .document('tradeOffers/{tradeId}')
    .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    if (!before || !after)
        return null;
    const beforeStatus = before.status;
    const afterStatus = after.status;
    // Only trigger when status changes to 'completed'
    if (beforeStatus !== 'completed' && afterStatus === 'completed') {
        const fromUserId = after.fromUserId;
        const toUserId = after.toUserId;
        if (!fromUserId || !toUserId)
            return null;
        try {
            // Increment totalTrades for both users
            await db.collection('users').doc(fromUserId).update({
                totalTrades: admin.firestore.FieldValue.increment(1),
            });
            await db.collection('users').doc(toUserId).update({
                totalTrades: admin.firestore.FieldValue.increment(1),
            });
            functions.logger.info('Trade completed - stats updated', { fromUserId, toUserId });
        }
        catch (error) {
            functions.logger.error('Error updating trade stats', { fromUserId, toUserId, error });
        }
    }
    return null;
});
//# sourceMappingURL=index.js.map