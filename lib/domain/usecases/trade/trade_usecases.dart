import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../entities/trade_offer_entity.dart';
import '../../repositories/trade_repository.dart';

/// Send Trade Offer Use Case
@injectable
class SendTradeOfferUseCase {
  final TradeRepository repository;

  SendTradeOfferUseCase(this.repository);

  Future<Either<Failure, TradeOfferEntity>> call(TradeOfferEntity offer) async {
    try {
      // Check if offer already exists
      final checkResult = await repository.checkExistingOffer(
        offer.fromUserId,
        offer.offeredItemId,
        offer.requestedItemId,
      );

      return checkResult.fold(
        (failure) => Left(failure),
        (exists) async {
          if (exists) {
            return Left(ValidationFailure('A trade offer already exists for these items'));
          }
          return await repository.sendTradeOffer(offer);
        },
      );
    } catch (e) {
      return Left(UnknownFailure('Failed to send trade offer: ${e.toString()}'));
    }
  }
}

/// Accept Trade Offer Use Case
@injectable
class AcceptTradeOfferUseCase {
  final TradeRepository repository;

  AcceptTradeOfferUseCase(this.repository);

  Future<Either<Failure, TradeOfferEntity>> call(
    String offerId, [
    String? responseMessage,
  ]) async {
    try {
      return await repository.acceptTradeOffer(offerId, responseMessage);
    } catch (e) {
      return Left(UnknownFailure('Failed to accept trade offer: ${e.toString()}'));
    }
  }
}

/// Reject Trade Offer Use Case
@injectable
class RejectTradeOfferUseCase {
  final TradeRepository repository;

  RejectTradeOfferUseCase(this.repository);

  Future<Either<Failure, TradeOfferEntity>> call(
    String offerId, [
    String? rejectionReason,
  ]) async {
    try {
      return await repository.rejectTradeOffer(offerId, rejectionReason);
    } catch (e) {
      return Left(UnknownFailure('Failed to reject trade offer: ${e.toString()}'));
    }
  }
}

/// Cancel Trade Offer Use Case (by sender)
@injectable
class CancelTradeOfferUseCase {
  final TradeRepository repository;

  CancelTradeOfferUseCase(this.repository);

  Future<Either<Failure, void>> call(String offerId) async {
    try {
      return await repository.cancelTradeOffer(offerId);
    } catch (e) {
      return Left(UnknownFailure('Failed to cancel trade offer: ${e.toString()}'));
    }
  }
}

/// Complete Trade Use Case
@injectable
class CompleteTradeUseCase {
  final TradeRepository repository;

  CompleteTradeUseCase(this.repository);

  Future<Either<Failure, TradeOfferEntity>> call(String offerId) async {
    try {
      return await repository.completeTrade(offerId);
    } catch (e) {
      return Left(UnknownFailure('Failed to complete trade: ${e.toString()}'));
    }
  }
}

/// Get Trade Offer Use Case
@injectable
class GetTradeOfferUseCase {
  final TradeRepository repository;

  GetTradeOfferUseCase(this.repository);

  Future<Either<Failure, TradeOfferEntity>> call(String offerId) async {
    try {
      return await repository.getTradeOffer(offerId);
    } catch (e) {
      return Left(UnknownFailure('Failed to get trade offer: ${e.toString()}'));
    }
  }
}

/// Get User Trade Offers Use Case (both sent and received)
@injectable
class GetUserTradeOffersUseCase {
  final TradeRepository repository;

  GetUserTradeOffersUseCase(this.repository);

  Future<Either<Failure, List<TradeOfferEntity>>> call(String userId) async {
    try {
      return await repository.getUserTradeOffers(userId);
    } catch (e) {
      return Left(UnknownFailure('Failed to get trade offers: ${e.toString()}'));
    }
  }
}

/// Get Sent Trade Offers Use Case
@injectable
class GetSentTradeOffersUseCase {
  final TradeRepository repository;

  GetSentTradeOffersUseCase(this.repository);

  Future<Either<Failure, List<TradeOfferEntity>>> call(String userId) async {
    try {
      return await repository.getSentTradeOffers(userId);
    } catch (e) {
      return Left(UnknownFailure('Failed to get sent trade offers: ${e.toString()}'));
    }
  }
}

/// Get Received Trade Offers Use Case
@injectable
class GetReceivedTradeOffersUseCase {
  final TradeRepository repository;

  GetReceivedTradeOffersUseCase(this.repository);

  Future<Either<Failure, List<TradeOfferEntity>>> call(String userId) async {
    try {
      return await repository.getReceivedTradeOffers(userId);
    } catch (e) {
      return Left(UnknownFailure('Failed to get received trade offers: ${e.toString()}'));
    }
  }
}

/// Get Trade Offers by Status Use Case
@injectable
class GetTradeOffersByStatusUseCase {
  final TradeRepository repository;

  GetTradeOffersByStatusUseCase(this.repository);

  Future<Either<Failure, List<TradeOfferEntity>>> call(
    String userId,
    TradeStatus status,
  ) async {
    try {
      return await repository.getTradeOffersByStatus(userId, status);
    } catch (e) {
      return Left(UnknownFailure('Failed to get trade offers by status: ${e.toString()}'));
    }
  }
}

/// Get Item Trade History Use Case
@injectable
class GetItemTradeHistoryUseCase {
  final TradeRepository repository;

  GetItemTradeHistoryUseCase(this.repository);

  Future<Either<Failure, List<TradeOfferEntity>>> call(String itemId) async {
    try {
      return await repository.getItemTradeHistory(itemId);
    } catch (e) {
      return Left(UnknownFailure('Failed to get item trade history: ${e.toString()}'));
    }
  }
}

/// Get Pending Received Trade Count Use Case
@injectable
class GetPendingReceivedCountUseCase {
  final TradeRepository repository;

  GetPendingReceivedCountUseCase(this.repository);

  Future<Either<Failure, int>> call(String userId) async {
    try {
      return await repository.getPendingReceivedCount(userId);
    } catch (e) {
      return Left(UnknownFailure('Failed to get pending trade count: ${e.toString()}'));
    }
  }
}
