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
exports.getMatchingItemsForCondition = exports.calculateBarterMatch = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const db = admin.firestore();
/**
 * Calculate Barter Match
 * İki ilan arasında uyumluluk skorunu hesaplar
 *
 * @param data - { offeredItemId, requestedItemId }
 * @returns BarterMatchResponse
 */
exports.calculateBarterMatch = functions.https.onCall(async (data, context) => {
    // Auth check
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }
    const { offeredItemId, requestedItemId } = data;
    // Validation
    if (!offeredItemId || !requestedItemId) {
        throw new functions.https.HttpsError('invalid-argument', 'Both offeredItemId and requestedItemId are required');
    }
    if (offeredItemId === requestedItemId) {
        throw new functions.https.HttpsError('invalid-argument', 'Cannot match the same item');
    }
    try {
        // Fetch both items
        const [offeredDoc, requestedDoc] = await Promise.all([
            db.collection('items').doc(offeredItemId).get(),
            db.collection('items').doc(requestedItemId).get(),
        ]);
        if (!offeredDoc.exists || !requestedDoc.exists) {
            throw new functions.https.HttpsError('not-found', 'One or both items not found');
        }
        const offeredItem = offeredDoc.data();
        const requestedItem = requestedDoc.data();
        // Calculate compatibility score
        let compatibilityScore = 0;
        let reason = '';
        let suggestedCash;
        let suggestedDirection;
        // 1. Value compatibility (50% weight)
        if (offeredItem.monetaryValue && requestedItem.monetaryValue) {
            const valueDiff = Math.abs(offeredItem.monetaryValue - requestedItem.monetaryValue);
            const avgValue = (offeredItem.monetaryValue + requestedItem.monetaryValue) / 2;
            const valueDiffPercent = (valueDiff / avgValue) * 100;
            if (valueDiffPercent < 10) {
                compatibilityScore += 50;
            }
            else if (valueDiffPercent < 30) {
                compatibilityScore += 30;
            }
            else {
                compatibilityScore += 10;
                // Suggest cash differential
                suggestedCash = Math.round(valueDiff / 50) * 50; // Round to nearest 50
                suggestedDirection =
                    offeredItem.monetaryValue > requestedItem.monetaryValue ? 'toMe' : 'fromMe';
            }
        }
        else {
            compatibilityScore += 25;
        }
        // 2. Category compatibility (20% weight)
        if (requestedItem.barterCondition?.type === 'categorySpecific') {
            const acceptedCategories = requestedItem.barterCondition.acceptedCategories || [];
            if (acceptedCategories.includes(offeredItem.category)) {
                compatibilityScore += 20;
            }
        }
        else {
            compatibilityScore += 10; // Flexible condition
        }
        // 3. Condition compatibility (15% weight)
        if (offeredItem.condition === requestedItem.condition) {
            compatibilityScore += 15;
        }
        else {
            compatibilityScore += 5;
        }
        // 4. Location proximity (15% weight)
        if (offeredItem.city && requestedItem.city) {
            if (offeredItem.city === requestedItem.city) {
                compatibilityScore += 15;
            }
            else {
                compatibilityScore += 5;
            }
        }
        else {
            compatibilityScore += 7;
        }
        // Determine match
        const isMatch = compatibilityScore >= 60;
        if (isMatch) {
            reason = `Good match! Score: ${Math.round(compatibilityScore)}/100`;
        }
        else {
            reason = `Low compatibility. Score: ${Math.round(compatibilityScore)}/100. Try other options.`;
        }
        // Log analytics
        functions.logger.info('Barter match calculated', {
            offeredItemId,
            requestedItemId,
            compatibilityScore,
            isMatch,
        });
        return {
            isMatch,
            compatibilityScore: Math.round(compatibilityScore),
            reason,
            suggestedCashDifferential: suggestedCash,
            suggestedPaymentDirection: suggestedDirection,
        };
    }
    catch (error) {
        functions.logger.error('Error calculating barter match', error);
        throw new functions.https.HttpsError('internal', 'Failed to calculate barter match');
    }
});
/**
 * Get Matching Items for Barter Condition
 * Belirli bir barter şartına uygun ilanları getirir
 */
exports.getMatchingItemsForCondition = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }
    const { conditionType, currentItemId, limit = 20 } = data;
    try {
        let query = db
            .collection('items')
            .where('status', '==', 'active')
            .where('moderationStatus', '==', 'approved')
            .limit(limit);
        const snapshot = await query.get();
        const items = snapshot.docs
            .filter((doc) => doc.id !== currentItemId)
            .map((doc) => ({
            id: doc.id,
            ...doc.data(),
        }));
        functions.logger.info('Fetched matching items', {
            conditionType,
            count: items.length,
        });
        return { items };
    }
    catch (error) {
        functions.logger.error('Error fetching matching items', error);
        throw new functions.https.HttpsError('internal', 'Failed to fetch matching items');
    }
});
//# sourceMappingURL=matchingAlgorithm.js.map