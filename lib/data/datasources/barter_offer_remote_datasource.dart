import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../models/barter_offer_model.dart';
import '../../domain/entities/barter_offer_entity.dart';

/// Remote data source for barter offers using Firestore
@lazySingleton
class BarterOfferRemoteDataSource {
  final FirebaseFirestore _firestore;

  static const String _collectionName = 'barter_offers';

  BarterOfferRemoteDataSource(this._firestore);

  /// Create a new offer in Firestore
  Future<BarterOfferModel> createOffer(BarterOfferModel offer) async {
    try {
      // Generate new document reference
      final docRef = _firestore.collection(_collectionName).doc();
      
      // Create offer with generated ID
      final offerWithId = offer.copyWith(id: docRef.id);
      
      // Save to Firestore
      await docRef.set(offerWithId.toFirestore());
      
      return offerWithId;
    } catch (e) {
      throw Exception('Failed to create offer: $e');
    }
  }

  /// Get a specific offer by ID
  Future<BarterOfferModel> getOffer(String offerId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(offerId)
          .get();

      if (!doc.exists) {
        throw Exception('Offer not found');
      }

      return BarterOfferModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get offer: $e');
    }
  }

  /// Get all offers sent by a user
  Future<List<BarterOfferModel>> getSentOffers(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('senderId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BarterOfferModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sent offers: $e');
    }
  }

  /// Get all offers received by a user
  Future<List<BarterOfferModel>> getReceivedOffers(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('recipientId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BarterOfferModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get received offers: $e');
    }
  }

  /// Get all offers for a specific item (both offered and requested)
  Future<List<BarterOfferModel>> getOffersForItem(String itemId) async {
    try {
      // Get offers where item is offered
      final offeredQuery = await _firestore
          .collection(_collectionName)
          .where('offeredItemId', isEqualTo: itemId)
          .orderBy('createdAt', descending: true)
          .get();

      // Get offers where item is requested
      final requestedQuery = await _firestore
          .collection(_collectionName)
          .where('requestedItemId', isEqualTo: itemId)
          .orderBy('createdAt', descending: true)
          .get();

      // Combine and deduplicate
      final offersMap = <String, BarterOfferModel>{};
      
      for (final doc in offeredQuery.docs) {
        offersMap[doc.id] = BarterOfferModel.fromFirestore(doc);
      }
      
      for (final doc in requestedQuery.docs) {
        offersMap[doc.id] = BarterOfferModel.fromFirestore(doc);
      }

      // Convert to list and sort by creation date
      final offers = offersMap.values.toList();
      offers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return offers;
    } catch (e) {
      throw Exception('Failed to get offers for item: $e');
    }
  }

  /// Update offer status
  Future<BarterOfferModel> updateOfferStatus(
    String offerId,
    OfferStatus newStatus,
  ) async {
    try {
      final now = DateTime.now();
      
      await _firestore.collection(_collectionName).doc(offerId).update({
        'status': newStatus.toValue(),
        'updatedAt': Timestamp.fromDate(now),
        if (newStatus == OfferStatus.accepted || 
            newStatus == OfferStatus.rejected)
          'respondedAt': Timestamp.fromDate(now),
      });

      return await getOffer(offerId);
    } catch (e) {
      throw Exception('Failed to update offer status: $e');
    }
  }

  /// Accept an offer
  Future<BarterOfferModel> acceptOffer(String offerId) async {
    return await updateOfferStatus(offerId, OfferStatus.accepted);
  }

  /// Reject an offer
  Future<BarterOfferModel> rejectOffer(String offerId) async {
    return await updateOfferStatus(offerId, OfferStatus.rejected);
  }

  /// Cancel an offer
  Future<BarterOfferModel> cancelOffer(String offerId) async {
    return await updateOfferStatus(offerId, OfferStatus.cancelled);
  }

  /// Mark offer as completed
  Future<BarterOfferModel> completeOffer(String offerId) async {
    return await updateOfferStatus(offerId, OfferStatus.completed);
  }

  /// Expire old offers (offers older than 24 hours that are still pending)
  Future<int> expireOldOffers() async {
    try {
      final now = DateTime.now();
      final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));

      // Query pending offers older than 24 hours
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: 'pending')
          .where('createdAt', isLessThan: Timestamp.fromDate(twentyFourHoursAgo))
          .get();

      // Batch update to expired status
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'status': 'expired',
          'updatedAt': Timestamp.fromDate(now),
        });
      }

      await batch.commit();
      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to expire old offers: $e');
    }
  }

  /// Get count of pending offers received by user
  Future<int> getPendingOffersCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('recipientId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get pending offers count: $e');
    }
  }

  /// Stream of sent offers (real-time updates)
  Stream<List<BarterOfferModel>> watchSentOffers(String userId) {
    try {
      return _firestore
          .collection(_collectionName)
          .where('senderId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => BarterOfferModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      throw Exception('Failed to watch sent offers: $e');
    }
  }

  /// Stream of received offers (real-time updates)
  Stream<List<BarterOfferModel>> watchReceivedOffers(String userId) {
    try {
      return _firestore
          .collection(_collectionName)
          .where('recipientId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => BarterOfferModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      throw Exception('Failed to watch received offers: $e');
    }
  }

  /// Delete an offer (for testing/admin purposes)
  Future<void> deleteOffer(String offerId) async {
    try {
      await _firestore.collection(_collectionName).doc(offerId).delete();
    } catch (e) {
      throw Exception('Failed to delete offer: $e');
    }
  }
}
