import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/barter_offer_entity.dart';

/// Repository interface for barter offers
/// 
/// Defines all operations related to creating, retrieving, and managing
/// barter offers between users.
abstract class BarterOfferRepository {
  /// Create a new barter offer
  /// 
  /// [offer] - The offer entity to create
  /// Returns [Right(BarterOfferEntity)] on success
  /// Returns [Left(Failure)] on error
  Future<Either<Failure, BarterOfferEntity>> createOffer(
    BarterOfferEntity offer,
  );

  /// Get a specific offer by ID
  /// 
  /// [offerId] - The unique identifier of the offer
  /// Returns [Right(BarterOfferEntity)] on success
  /// Returns [Left(Failure)] on error
  Future<Either<Failure, BarterOfferEntity>> getOffer(String offerId);

  /// Get all offers sent by a specific user
  /// 
  /// [userId] - The ID of the user who sent the offers
  /// Returns [Right(List<BarterOfferEntity>)] on success
  /// Returns [Left(Failure)] on error
  Future<Either<Failure, List<BarterOfferEntity>>> getSentOffers(
    String userId,
  );

  /// Get all offers received by a specific user
  /// 
  /// [userId] - The ID of the user who received the offers
  /// Returns [Right(List<BarterOfferEntity>)] on success
  /// Returns [Left(Failure)] on error
  Future<Either<Failure, List<BarterOfferEntity>>> getReceivedOffers(
    String userId,
  );

  /// Get all offers for a specific item
  /// 
  /// [itemId] - The ID of the item
  /// Returns [Right(List<BarterOfferEntity>)] on success
  /// Returns [Left(Failure)] on error
  Future<Either<Failure, List<BarterOfferEntity>>> getOffersForItem(
    String itemId,
  );

  /// Accept an offer
  /// 
  /// [offerId] - The ID of the offer to accept
  /// Returns [Right(BarterOfferEntity)] with updated status on success
  /// Returns [Left(Failure)] on error
  Future<Either<Failure, BarterOfferEntity>> acceptOffer(String offerId);

  /// Reject an offer
  /// 
  /// [offerId] - The ID of the offer to reject
  /// Returns [Right(BarterOfferEntity)] with updated status on success
  /// Returns [Left(Failure)] on error
  Future<Either<Failure, BarterOfferEntity>> rejectOffer(String offerId);

  /// Cancel an offer
  /// 
  /// [offerId] - The ID of the offer to cancel
  /// Returns [Right(BarterOfferEntity)] with updated status on success
  /// Returns [Left(Failure)] on error
  Future<Either<Failure, BarterOfferEntity>> cancelOffer(String offerId);

  /// Mark an offer as completed
  /// 
  /// [offerId] - The ID of the offer to mark as completed
  /// Returns [Right(BarterOfferEntity)] with updated status on success
  /// Returns [Left(Failure)] on error
  Future<Either<Failure, BarterOfferEntity>> completeOffer(String offerId);

  /// Update offer status to expired for offers that have exceeded their expiration time
  /// 
  /// This is typically called by a background job or when listing offers
  /// Returns [Right(int)] with the number of offers expired on success
  /// Returns [Left(Failure)] on error
  Future<Either<Failure, int>> expireOldOffers();

  /// Get count of pending offers received by a user
  /// 
  /// Useful for displaying notification badges
  /// [userId] - The ID of the user
  /// Returns [Right(int)] with the count on success
  /// Returns [Left(Failure)] on error
  Future<Either<Failure, int>> getPendingOffersCount(String userId);

  /// Stream of offers sent by a user (real-time updates)
  /// 
  /// [userId] - The ID of the user who sent the offers
  /// Returns a stream of lists of offers
  Stream<Either<Failure, List<BarterOfferEntity>>> watchSentOffers(
    String userId,
  );

  /// Stream of offers received by a user (real-time updates)
  /// 
  /// [userId] - The ID of the user who received the offers
  /// Returns a stream of lists of offers
  Stream<Either<Failure, List<BarterOfferEntity>>> watchReceivedOffers(
    String userId,
  );
}
