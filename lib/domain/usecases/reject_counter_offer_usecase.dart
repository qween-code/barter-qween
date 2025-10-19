import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../entities/counter_offer_entity.dart';

/// Use case for rejecting a counter-offer
///
/// Allows user to reject a counter-offer and optionally
/// send a new counter-offer or end negotiation
@lazySingleton
class RejectCounterOfferUsecase {
  RejectCounterOfferUsecase();

  /// Execute the use case
  Future<Either<Failure, RejectCounterOfferResult>> call(
    RejectCounterOfferParams params,
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
      // TODO: Validate user can reject (must be target user)
      // TODO: Validate counter-offer is still valid

      final now = DateTime.now();

      // Create result
      // In real implementation, this would:
      // 1. Update counter-offer status to 'rejected'
      // 2. Update negotiation state
      // 3. Optionally end negotiation if endNegotiation=true
      // 4. Send notification to other party

      final result = RejectCounterOfferResult(
        counterOfferId: params.counterOfferId,
        negotiationId: '', // TODO: Get from counter-offer
        negotiationEnded: params.endNegotiation,
        reason: params.reason,
        rejectedAt: now,
      );

      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Validate if user can reject counter-offer
  bool canRejectCounterOffer({
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

    // Must not be expired (though expired offers are auto-rejected)
    if (counterOffer.isExpired) {
      return false;
    }

    return true;
  }

  /// Generate rejection message
  String generateRejectionMessage({
    required String userName,
    String? reason,
    bool endingNegotiation = false,
  }) {
    if (endingNegotiation) {
      return reason != null && reason.isNotEmpty
          ? '$userName müzakereyi sonlandırdı: $reason'
          : '$userName müzakereyi sonlandırdı.';
    }

    return reason != null && reason.isNotEmpty
        ? '$userName karşı teklifi reddetti: $reason'
        : '$userName karşı teklifi reddetti.';
  }
}

/// Parameters for rejecting counter-offer
class RejectCounterOfferParams {
  final String counterOfferId;
  final String userId; // User rejecting
  final String? reason; // Optional rejection reason
  final bool endNegotiation; // Should we end the entire negotiation?

  RejectCounterOfferParams({
    required this.counterOfferId,
    required this.userId,
    this.reason,
    this.endNegotiation = false,
  });

  /// Quick reject (no reason)
  factory RejectCounterOfferParams.quick({
    required String counterOfferId,
    required String userId,
  }) {
    return RejectCounterOfferParams(
      counterOfferId: counterOfferId,
      userId: userId,
    );
  }

  /// Reject with reason
  factory RejectCounterOfferParams.withReason({
    required String counterOfferId,
    required String userId,
    required String reason,
  }) {
    return RejectCounterOfferParams(
      counterOfferId: counterOfferId,
      userId: userId,
      reason: reason,
    );
  }

  /// Reject and end negotiation
  factory RejectCounterOfferParams.endNegotiation({
    required String counterOfferId,
    required String userId,
    String? reason,
  }) {
    return RejectCounterOfferParams(
      counterOfferId: counterOfferId,
      userId: userId,
      reason: reason,
      endNegotiation: true,
    );
  }
}

/// Result of rejecting counter-offer
class RejectCounterOfferResult {
  final String counterOfferId;
  final String negotiationId;
  final bool negotiationEnded; // Was negotiation ended?
  final String? reason;
  final DateTime rejectedAt;

  RejectCounterOfferResult({
    required this.counterOfferId,
    required this.negotiationId,
    required this.negotiationEnded,
    this.reason,
    required this.rejectedAt,
  });

  /// Get status message
  String get statusMessage {
    if (negotiationEnded) {
      return 'Müzakere sonlandırıldı.';
    }
    return 'Karşı teklif reddedildi.';
  }

  /// Can continue negotiation?
  bool get canContinue => !negotiationEnded;
}
