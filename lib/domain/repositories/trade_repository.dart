import 'package:dartz/dartz.dart';
import '../entities/trade_offer_entity.dart';
import '../../core/error/failures.dart';

/// Repository interface for Trade operations
abstract class TradeRepository {
  /// Send a trade offer
  Future<Either<Failure, TradeOfferEntity>> sendTradeOffer(TradeOfferEntity offer);

  /// Accept a trade offer
  Future<Either<Failure, TradeOfferEntity>> acceptTradeOffer(String offerId, String? responseMessage);

  /// Reject a trade offer
  Future<Either<Failure, TradeOfferEntity>> rejectTradeOffer(String offerId, String? rejectionReason);

  /// Cancel a trade offer (by sender)
  Future<Either<Failure, void>> cancelTradeOffer(String offerId);

  /// Complete a trade
  Future<Either<Failure, TradeOfferEntity>> completeTrade(String offerId);

  /// Get a single trade offer by ID
  Future<Either<Failure, TradeOfferEntity>> getTradeOffer(String offerId);

  /// Get all trade offers for a user (both sent and received)
  Future<Either<Failure, List<TradeOfferEntity>>> getUserTradeOffers(String userId);

  /// Get trade offers sent by a user
  Future<Either<Failure, List<TradeOfferEntity>>> getSentTradeOffers(String userId);

  /// Get trade offers received by a user
  Future<Either<Failure, List<TradeOfferEntity>>> getReceivedTradeOffers(String userId);

  /// Get trade offers by status for a user
  Future<Either<Failure, List<TradeOfferEntity>>> getTradeOffersByStatus(
    String userId,
    TradeStatus status,
  );

  /// Get trade history for an item
  Future<Either<Failure, List<TradeOfferEntity>>> getItemTradeHistory(String itemId);

  /// Check if a trade offer already exists between two items
  Future<Either<Failure, bool>> checkExistingOffer(
    String fromUserId,
    String offeredItemId,
    String requestedItemId,
  );

  /// Get count of pending received trade offers
  Future<Either<Failure, int>> getPendingReceivedCount(String userId);
}
