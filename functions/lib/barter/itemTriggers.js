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
exports.onItemUpdated = exports.onItemCreated = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const db = admin.firestore();
/**
 * Trigger: When a new item is created with barter conditions
 * Automatically calculate and create barter matches
 */
exports.onItemCreated = functions.firestore
    .document('items/{itemId}')
    .onCreate(async (snap, context) => {
    const itemData = snap.data();
    const itemId = context.params.itemId;
    // Only process items with barter conditions
    if (!itemData.barterCondition) {
        functions.logger.info(`Item ${itemId} has no barter conditions, skipping match calculation`);
        return;
    }
    try {
        functions.logger.info(`Processing new item ${itemId} for barter matches`);
        // Find potential matches
        const potentialMatches = await findPotentialMatches(itemId, itemData);
        // Calculate match scores and create barter matches
        for (const targetItem of potentialMatches) {
            const matchScore = await calculateMatchScore(itemData, targetItem.data());
            if (matchScore.matchScore >= 40) { // Only create matches with score >= 40%
                await createBarterMatch(itemId, targetItem.id, itemData, targetItem.data(), matchScore);
            }
        }
        functions.logger.info(`Created barter matches for item ${itemId}`);
    }
    catch (error) {
        functions.logger.error(`Error processing item ${itemId}:`, error);
    }
});
/**
 * Trigger: When an item is updated
 * Recalculate matches if barter conditions changed
 */
exports.onItemUpdated = functions.firestore
    .document('items/{itemId}')
    .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    const itemId = context.params.itemId;
    // Check if barter conditions changed
    const barterConditionsChanged = JSON.stringify(beforeData.barterCondition) !==
        JSON.stringify(afterData.barterCondition);
    if (!barterConditionsChanged) {
        return;
    }
    try {
        functions.logger.info(`Barter conditions changed for item ${itemId}, recalculating matches`);
        // Delete existing matches for this item
        await deleteExistingMatches(itemId);
        // Only recalculate if item still has barter conditions
        if (afterData.barterCondition) {
            const potentialMatches = await findPotentialMatches(itemId, afterData);
            for (const targetItem of potentialMatches) {
                const matchScore = await calculateMatchScore(afterData, targetItem.data());
                if (matchScore.matchScore >= 40) {
                    await createBarterMatch(itemId, targetItem.id, afterData, targetItem.data(), matchScore);
                }
            }
        }
        functions.logger.info(`Updated barter matches for item ${itemId}`);
    }
    catch (error) {
        functions.logger.error(`Error updating matches for item ${itemId}:`, error);
    }
});
/**
 * Find potential matches for an item
 */
async function findPotentialMatches(sourceItemId, sourceItemData) {
    const sourceCategory = sourceItemData.category;
    const sourcePrice = sourceItemData.price || 0;
    const sourceLocation = sourceItemData;
    // Query for items in same category with barter conditions
    const query = db.collection('items')
        .where('category', '==', sourceCategory)
        .where('status', '==', 'available')
        .where('barterCondition', '!=', null)
        .limit(50); // Limit to prevent timeout
    const snapshot = await query.get();
    // Filter out the source item and items from same owner
    return snapshot.docs.filter(doc => doc.id !== sourceItemId &&
        doc.data().ownerId !== sourceItemData.ownerId);
}
/**
 * Calculate match score between two items
 */
async function calculateMatchScore(sourceItem, targetItem) {
    let categoryScore = 0;
    let priceScore = 0;
    let locationScore = 0;
    let trustScore = 0;
    let conditionScore = 0;
    // Category match (30% weight)
    if (sourceItem.category === targetItem.category) {
        categoryScore = 100;
    }
    else if (sourceItem.subcategory === targetItem.subcategory) {
        categoryScore = 80;
    }
    else {
        categoryScore = 40; // Related category
    }
    // Price similarity (25% weight)
    const sourcePrice = sourceItem.price || 0;
    const targetPrice = targetItem.price || 0;
    if (sourcePrice > 0 && targetPrice > 0) {
        const priceDiff = Math.abs(sourcePrice - targetPrice) / Math.max(sourcePrice, targetPrice);
        priceScore = Math.max(0, 100 - (priceDiff * 100));
    }
    else {
        priceScore = 50; // Neutral score if no price
    }
    // Location proximity (20% weight)
    if (sourceItem.latitude && sourceItem.longitude &&
        targetItem.latitude && targetItem.longitude) {
        const distance = calculateDistance(sourceItem.latitude, sourceItem.longitude, targetItem.latitude, targetItem.longitude);
        if (distance <= 5) {
            locationScore = 100;
        }
        else if (distance <= 15) {
            locationScore = 80;
        }
        else if (distance <= 30) {
            locationScore = 60;
        }
        else {
            locationScore = 40;
        }
    }
    else {
        locationScore = 50; // Neutral if no location
    }
    // Trust score (15% weight) - get user trust scores
    try {
        const sourceUserDoc = await db.collection('users').doc(sourceItem.ownerId).get();
        const targetUserDoc = await db.collection('users').doc(targetItem.ownerId).get();
        const sourceTrustScore = sourceUserDoc.data()?.trustScore || 50;
        const targetTrustScore = targetUserDoc.data()?.trustScore || 50;
        trustScore = (sourceTrustScore + targetTrustScore) / 2;
    }
    catch (error) {
        trustScore = 50; // Default if user data not found
    }
    // Condition match (10% weight)
    if (sourceItem.condition === targetItem.condition) {
        conditionScore = 100;
    }
    else {
        conditionScore = 60; // Partial match
    }
    // Calculate weighted overall score
    const overallScore = (categoryScore * 0.30) +
        (priceScore * 0.25) +
        (locationScore * 0.20) +
        (trustScore * 0.15) +
        (conditionScore * 0.10);
    // Determine match quality
    let quality = 'poor';
    if (overallScore >= 80)
        quality = 'excellent';
    else if (overallScore >= 65)
        quality = 'good';
    else if (overallScore >= 50)
        quality = 'fair';
    // Generate match reasons
    const matchReasons = [];
    if (categoryScore >= 80)
        matchReasons.push('Same category');
    if (priceScore >= 70)
        matchReasons.push('Similar price range');
    if (locationScore >= 80)
        matchReasons.push('Close location');
    if (trustScore >= 80)
        matchReasons.push('High trust users');
    if (conditionScore >= 80)
        matchReasons.push('Matching condition');
    // Generate concerns
    const concerns = [];
    if (priceScore < 50)
        concerns.push('Significant price difference');
    if (locationScore < 50)
        concerns.push('Far distance for meetup');
    if (trustScore < 50)
        concerns.push('Lower trust scores');
    return {
        matchScore: Math.round(overallScore * 10) / 10,
        categoryScore: Math.round(categoryScore * 10) / 10,
        priceScore: Math.round(priceScore * 10) / 10,
        locationScore: Math.round(locationScore * 10) / 10,
        trustScore: Math.round(trustScore * 10) / 10,
        conditionScore: Math.round(conditionScore * 10) / 10,
        quality,
        matchReasons,
        concerns: concerns.length > 0 ? concerns : null,
        distanceKm: sourceItem.latitude && targetItem.latitude ?
            calculateDistance(sourceItem.latitude, sourceItem.longitude, targetItem.latitude, targetItem.longitude) : null,
        suggestedCashDifferential: calculateCashDifferential(sourceItem.price, targetItem.price),
        cashDirection: sourceItem.price > targetItem.price ? 'fromInitiator' : 'toInitiator',
        conditionsCompatible: true, // TODO: Implement barter condition compatibility
        compatibilityNote: 'Barter conditions compatible'
    };
}
/**
 * Create a barter match document
 */
async function createBarterMatch(sourceItemId, targetItemId, sourceItem, targetItem, matchData) {
    const matchId = `${sourceItemId}_${targetItemId}`;
    const barterMatch = {
        id: matchId,
        sourceItemId,
        targetItemId,
        sourceUserId: sourceItem.ownerId,
        targetUserId: targetItem.ownerId,
        // Match scoring
        matchScore: matchData.matchScore,
        categoryScore: matchData.categoryScore,
        priceScore: matchData.priceScore,
        locationScore: matchData.locationScore,
        trustScore: matchData.trustScore,
        conditionScore: matchData.conditionScore,
        // Match details
        quality: matchData.quality,
        matchReasons: matchData.matchReasons,
        concerns: matchData.concerns,
        // Distance & location
        distanceKm: matchData.distanceKm,
        locationDescription: matchData.distanceKm ?
            `${matchData.distanceKm.toFixed(1)} km away` : null,
        // Barter conditions compatibility
        conditionsCompatible: matchData.conditionsCompatible,
        compatibilityNote: matchData.compatibilityNote,
        // Cash differential
        suggestedCashDifferential: matchData.suggestedCashDifferential,
        cashDirection: matchData.cashDirection,
        // Metadata
        calculatedAt: admin.firestore.FieldValue.serverTimestamp(),
        isSeen: false,
        isDismissed: false,
        viewCount: 0,
        wasOffered: false
    };
    await db.collection('barter_matches').doc(matchId).set(barterMatch);
}
/**
 * Delete existing matches for an item
 */
async function deleteExistingMatches(itemId) {
    const matchesQuery = db.collection('barter_matches')
        .where('sourceItemId', '==', itemId);
    const snapshot = await matchesQuery.get();
    const batch = db.batch();
    snapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
    });
    await batch.commit();
}
/**
 * Calculate distance between two coordinates using Haversine formula
 */
function calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Earth's radius in kilometers
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
            Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
}
/**
 * Calculate suggested cash differential
 */
function calculateCashDifferential(sourcePrice, targetPrice) {
    if (!sourcePrice || !targetPrice)
        return null;
    const diff = Math.abs(sourcePrice - targetPrice);
    return diff > 50 ? Math.round(diff) : null; // Only suggest if difference > ₺50
}
//# sourceMappingURL=itemTriggers.js.map