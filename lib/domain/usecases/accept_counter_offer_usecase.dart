import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../entities/counter_offer_entity.dart';
import '../entities/negotiation_entity.dart';
import '../entities/trade_entity.dart';

/// Use case for accepting a counter-offer
///
/// Validates acceptance permissions, updates negotiation state,
/// and potentially creates a trade if terms are finalized
@lazySingleton
class AcceptCounterOfferUsecase {
  AcceptCounterOfferUsecase();

  /// Execute the use case
  ///
  /// Accepts the counter-offer and updates negotiation/trade state
  Future<Either<Failure, AcceptCounterOfferResult>> call(
    AcceptCounterOfferParams params,
  ) async {
    try {
      // Validate params
      if (params.counterOfferId.isEmpty) {
        return Left(ValidationFailure('Counter-offer ID is required'));
      }
      if (params.userId.isEmpty) {
        return Left(ValidationFailure('User ID is required'));
      }

      // TODO: Get counter-offer from repository
      // TODO: Validate user can accept (must be target user)
      // TODO: Validate counter-offer is still valid (not expired)

      final now = DateTime.now();

      // Create result placeholder
      // In real implementation, this would:
      // 1. Update counter-offer status to 'accepted'
      // 2. Update negotiation with accepted terms
      // 3. Mark negotiation as 'agreed'
      // 4. Optionally create Trade entity
      // 5. Send notification to other party

      final result = AcceptCounterOfferResult(
        counterOfferId: params.counterOfferId,
        negotiationId: '', // TODO: Get from counter-offer
        isNegotiationComplete: params.createTrade,
        tradeCreated: params.createTrade,
        trade: params.createTrade ? _createTradeFromAcceptance(params) : null,
        acceptedAt: now,
      );

      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Create trade from accepted counter-offer
  TradeEntity? _createTradeFromAcceptance(AcceptCounterOfferParams params) {
    // TODO: Get actual offer/negotiation data
    // This is placeholder - real implementation would get data from repository

    final now = DateTime.now();
    return TradeEntity(
      id: '',
      offerId: '', // TODO: Get from negotiation
      initiatorId: '', // TODO: Get from negotiation
      initiatorItemId: '', // TODO: Get from offer
      receiverId: '', // TODO: Get from negotiation
      receiverItemId: '', // TODO: Get from offer
      status: TradeStatus.pending,
      agreedAt: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Validate if user can accept counter-offer
  bool canAcceptCounterOffer({
    required String userId,
    required CounterOfferEntity counterOffer,
  }) {
    // User must be the target
    if (userId != counterOffer.targetUserId) {
      return false;
    }

    // Counter-offer must be pending
    if (counterOffer.status != CounterOfferStatus.pending) {
      return false;
    }

    // Must not be expired
    if (counterOffer.isExpired) {
      return false;
    }

    return true;
  }

  /// Calculate if acceptance should create trade
  bool shouldCreateTrade({
    required NegotiationEntity negotiation,
    required CounterOfferEntity counterOffer,
  }) {
    // If it's a full counter-offer and accepted, create trade
    if (counterOffer.type == CounterOfferType.full) {
      return true;
    }

    // If negotiation has been going for multiple rounds
    // and terms are sufficiently defined
    if (negotiation.roundCount >= 2 &&
        negotiation.currentCashOffer != null &&
        negotiation.currentMeetupLocation != null) {
      return true;
    }

    return false;
  }
}

/// Parameters for accepting counter-offer
class AcceptCounterOfferParams {
  final String counterOfferId;
  final String userId; // User accepting
  final String? responseMessage; // Optional message
  final bool createTrade; // Should we create trade immediately?

  AcceptCounterOfferParams({
    required this.counterOfferId,
    required this.userId,
    this.responseMessage,
    this.createTrade = false,
  });
}

/// Result of accepting counter-offer
class AcceptCounterOfferResult {
  final String counterOfferId;
  final String negotiationId;
  final bool isNegotiationComplete; // Is negotiation finished?
  final bool tradeCreated; // Was trade created?
  final TradeEntity? trade; // Created trade (if any)
  final DateTime acceptedAt;

  AcceptCounterOfferResult({
    required this.counterOfferId,
    required this.negotiationId,
    required this.isNegotiationComplete,
    required this.tradeCreated,
    this.trade,
    required this.acceptedAt,
  });

  /// Get status message
  String get statusMessage {
    if (tradeCreated) {
      return 'Takas oluşturuldu! Buluşma detaylarını ayarlayabilirsiniz.';
    }
    if (isNegotiationComplete) {
      return 'Anlaşma sağlandı! Takas oluşturuluyor...';
    }
    return 'Karşı teklif kabul edildi.';
  }
}
