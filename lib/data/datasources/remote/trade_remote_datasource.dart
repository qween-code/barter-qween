import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/exceptions.dart';
import '../../../domain/entities/trade_offer_entity.dart';
import '../../models/trade_offer_model.dart';

abstract class TradeRemoteDataSource {
  Future<TradeOfferModel> sendTradeOffer(TradeOfferModel offer);
  Future<TradeOfferModel> acceptTradeOffer(String offerId, String? responseMessage);
  Future<TradeOfferModel> rejectTradeOffer(String offerId, String? rejectionReason);
  Future<void> cancelTradeOffer(String offerId);
  Future<TradeOfferModel> completeTrade(String offerId);
  Future<TradeOfferModel> getTradeOffer(String offerId);
  Future<List<TradeOfferModel>> getUserTradeOffers(String userId);
  Future<List<TradeOfferModel>> getSentTradeOffers(String userId);
  Future<List<TradeOfferModel>> getReceivedTradeOffers(String userId);
  Future<List<TradeOfferModel>> getTradeOffersByStatus(String userId, TradeStatus status);
  Future<List<TradeOfferModel>> getItemTradeHistory(String itemId);
  Future<bool> checkExistingOffer(String fromUserId, String offeredItemId, String requestedItemId);
  Future<int> getPendingReceivedCount(String userId);
}

@LazySingleton(as: TradeRemoteDataSource)
class TradeRemoteDataSourceImpl implements TradeRemoteDataSource {
  final FirebaseFirestore firestore;

  TradeRemoteDataSourceImpl({required this.firestore});

  @override
  Future<TradeOfferModel> sendTradeOffer(TradeOfferModel offer) async {
    try {
      final docRef = await firestore.collection('tradeOffers').add(offer.toFirestore());
      final doc = await docRef.get();
      return TradeOfferModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to send trade offer: ${e.toString()}');
    }
  }

  @override
  Future<TradeOfferModel> acceptTradeOffer(String offerId, String? responseMessage) async {
    try {
      final docRef = firestore.collection('tradeOffers').doc(offerId);
      
      await docRef.update({
        'status': 'accepted',
        'responseMessage': responseMessage,
        'respondedAt': FieldValue.serverTimestamp(),
      });

      final doc = await docRef.get();
      if (!doc.exists) {
        throw ServerException('Trade offer not found');
      }
      
      return TradeOfferModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to accept trade offer: ${e.toString()}');
    }
  }

  @override
  Future<TradeOfferModel> rejectTradeOffer(String offerId, String? rejectionReason) async {
    try {
      final docRef = firestore.collection('tradeOffers').doc(offerId);
      
      await docRef.update({
        'status': 'rejected',
        'rejectionReason': rejectionReason,
        'respondedAt': FieldValue.serverTimestamp(),
      });

      final doc = await docRef.get();
      if (!doc.exists) {
        throw ServerException('Trade offer not found');
      }
      
      return TradeOfferModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to reject trade offer: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelTradeOffer(String offerId) async {
    try {
      await firestore.collection('tradeOffers').doc(offerId).update({
        'status': 'cancelled',
        'respondedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to cancel trade offer: ${e.toString()}');
    }
  }

  @override
  Future<TradeOfferModel> completeTrade(String offerId) async {
    try {
      final docRef = firestore.collection('tradeOffers').doc(offerId);
      
      await docRef.update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      final doc = await docRef.get();
      if (!doc.exists) {
        throw ServerException('Trade offer not found');
      }
      
      return TradeOfferModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to complete trade: ${e.toString()}');
    }
  }

  @override
  Future<TradeOfferModel> getTradeOffer(String offerId) async {
    try {
      final doc = await firestore.collection('tradeOffers').doc(offerId).get();
      
      if (!doc.exists) {
        throw NotFoundException('Trade offer not found');
      }
      
      return TradeOfferModel.fromFirestore(doc);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException('Failed to get trade offer: ${e.toString()}');
    }
  }

  @override
  Future<List<TradeOfferModel>> getUserTradeOffers(String userId) async {
    try {
      print('💻 Fetching trade offers for user: $userId');
      
      // Get offers where user is sender (without orderBy to avoid index)
      final sentSnapshot = await firestore
          .collection('tradeOffers')
          .where('fromUserId', isEqualTo: userId)
          .get();

      print('📤 Sent offers: ${sentSnapshot.docs.length}');

      // Get offers where user is receiver (without orderBy to avoid index)
      final receivedSnapshot = await firestore
          .collection('tradeOffers')
          .where('toUserId', isEqualTo: userId)
          .get();

      print('📥 Received offers: ${receivedSnapshot.docs.length}');

      final allDocs = [...sentSnapshot.docs, ...receivedSnapshot.docs];
      
      // Remove duplicates and sort by createdAt in memory
      final uniqueDocs = <String, DocumentSnapshot>{};
      for (final doc in allDocs) {
        uniqueDocs[doc.id] = doc;
      }

      final offers = uniqueDocs.values
          .map((doc) => TradeOfferModel.fromFirestore(doc))
          .toList();
      
      // Sort in memory instead of Firestore
      offers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      print('✅ Total unique offers: ${offers.length}');
      
      return offers;
    } catch (e) {
      print('❌ Failed to get user trade offers: $e');
      throw ServerException('Failed to get user trade offers: ${e.toString()}');
    }
  }

  @override
  Future<List<TradeOfferModel>> getSentTradeOffers(String userId) async {
    try {
      final snapshot = await firestore
          .collection('tradeOffers')
          .where('fromUserId', isEqualTo: userId)
          .get(); // Removed orderBy to avoid index requirement

      final offers = snapshot.docs
          .map((doc) => TradeOfferModel.fromFirestore(doc))
          .toList();
      
      // Sort in memory
      offers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return offers;
    } catch (e) {
      throw ServerException('Failed to get sent trade offers: ${e.toString()}');
    }
  }

  @override
  Future<List<TradeOfferModel>> getReceivedTradeOffers(String userId) async {
    try {
      final snapshot = await firestore
          .collection('tradeOffers')
          .where('toUserId', isEqualTo: userId)
          .get(); // Removed orderBy to avoid index requirement

      final offers = snapshot.docs
          .map((doc) => TradeOfferModel.fromFirestore(doc))
          .toList();
      
      // Sort in memory
      offers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return offers;
    } catch (e) {
      throw ServerException('Failed to get received trade offers: ${e.toString()}');
    }
  }

  @override
  Future<List<TradeOfferModel>> getTradeOffersByStatus(
    String userId,
    TradeStatus status,
  ) async {
    try {
      final statusString = _statusToString(status);
      
      // Get offers where user is either sender or receiver with specific status
      final sentSnapshot = await firestore
          .collection('tradeOffers')
          .where('fromUserId', isEqualTo: userId)
          .where('status', isEqualTo: statusString)
          .orderBy('createdAt', descending: true)
          .get();

      final receivedSnapshot = await firestore
          .collection('tradeOffers')
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: statusString)
          .orderBy('createdAt', descending: true)
          .get();

      final allDocs = [...sentSnapshot.docs, ...receivedSnapshot.docs];
      
      // Remove duplicates
      final uniqueDocs = <String, DocumentSnapshot>{};
      for (final doc in allDocs) {
        uniqueDocs[doc.id] = doc;
      }

      final offers = uniqueDocs.values
          .map((doc) => TradeOfferModel.fromFirestore(doc))
          .toList();
      
      offers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return offers;
    } catch (e) {
      throw ServerException('Failed to get trade offers by status: ${e.toString()}');
    }
  }

  @override
  Future<List<TradeOfferModel>> getItemTradeHistory(String itemId) async {
    try {
      // Get all trades involving this item
      final offeredSnapshot = await firestore
          .collection('tradeOffers')
          .where('offeredItemId', isEqualTo: itemId)
          .orderBy('createdAt', descending: true)
          .get();

      final requestedSnapshot = await firestore
          .collection('tradeOffers')
          .where('requestedItemId', isEqualTo: itemId)
          .orderBy('createdAt', descending: true)
          .get();

      final allDocs = [...offeredSnapshot.docs, ...requestedSnapshot.docs];
      
      // Remove duplicates
      final uniqueDocs = <String, DocumentSnapshot>{};
      for (final doc in allDocs) {
        uniqueDocs[doc.id] = doc;
      }

      final offers = uniqueDocs.values
          .map((doc) => TradeOfferModel.fromFirestore(doc))
          .toList();
      
      offers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return offers;
    } catch (e) {
      throw ServerException('Failed to get item trade history: ${e.toString()}');
    }
  }

  @override
  Future<bool> checkExistingOffer(
    String fromUserId,
    String offeredItemId,
    String requestedItemId,
  ) async {
    try {
      // Query all offers from this user for these items
      final snapshot = await firestore
          .collection('tradeOffers')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('offeredItemId', isEqualTo: offeredItemId)
          .where('requestedItemId', isEqualTo: requestedItemId)
          .get();

      // Filter in memory for pending or accepted status
      final existingOffers = snapshot.docs.where((doc) {
        final status = doc.data()['status'] as String?;
        return status == 'pending' || status == 'accepted';
      }).toList();

      return existingOffers.isNotEmpty;
    } catch (e) {
      throw ServerException('Failed to check existing offer: ${e.toString()}');
    }
  }

  @override
  Future<int> getPendingReceivedCount(String userId) async {
    try {
      final snapshot = await firestore
          .collection('tradeOffers')
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw ServerException('Failed to get pending count: ${e.toString()}');
    }
  }

  String _statusToString(TradeStatus status) {
    switch (status) {
      case TradeStatus.pending:
        return 'pending';
      case TradeStatus.accepted:
        return 'accepted';
      case TradeStatus.rejected:
        return 'rejected';
      case TradeStatus.completed:
        return 'completed';
      case TradeStatus.cancelled:
        return 'cancelled';
      case TradeStatus.expired:
        return 'expired';
    }
  }
}
