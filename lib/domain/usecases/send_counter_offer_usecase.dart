import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../entities/counter_offer_entity.dart';
import '../entities/negotiation_entity.dart';

/// Use case for sending a counter-offer during negotiation
///
/// Validates the counter-offer, checks user permissions,
/// and creates the counter-offer entity
@lazySingleton
class SendCounterOfferUsecase {
  SendCounterOfferUsecase();

  /// Execute the use case
  ///
  /// Creates a counter-offer and updates the negotiation state
  Future<Either<Failure, CounterOfferEntity>> call(
    SendCounterOfferParams params,
  ) async {
    try {
      // Validate params
      final validationResult = _validateParams(params);
      if (validationResult != null) {
        return Left(ValidationFailure(validationResult));
      }

      // TODO: Get negotiation from repository to validate state
      // For now, create counter-offer entity directly

      final now = DateTime.now();
      final counterOffer = CounterOfferEntity(
        id: '', // Firestore will generate
        offerId: params.offerId,
        negotiationId: params.negotiationId,
        offererId: params.offererId,
        targetUserId: params.targetUserId,
        sourceItemId: '', // TODO: Get from negotiation
        targetItemId: '', // TODO: Get from negotiation
        type: params.type,
        offerType: params.type,
        proposedCash: params.proposedCash,
        proposedPaymentDirection: params.proposedPaymentDirection,
        proposedMeetupLocation: params.proposedMeetupLocation,
        proposedMeetupTime: params.proposedMeetupTime,
        message: params.message,
        status: CounterOfferStatus.pending,
        createdAt: now,
        expiresAt: params.expirationHours != null
            ? now.add(Duration(hours: params.expirationHours!))
            : now.add(const Duration(hours: 48)), // Default 48 hours
      );

      // TODO: Save to repository
      // TODO: Update negotiation with new round
      // TODO: Send notification to target user

      return Right(counterOffer);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Validate counter-offer parameters
  String? _validateParams(SendCounterOfferParams params) {
    if (params.negotiationId.isEmpty) {
      return 'Negotiation ID is required';
    }
    if (params.offerId.isEmpty) {
      return 'Offer ID is required';
    }
    if (params.offererId.isEmpty) {
      return 'Offerer ID is required';
    }
    if (params.targetUserId.isEmpty) {
      return 'Target user ID is required';
    }
    if (params.offererId == params.targetUserId) {
      return 'Cannot send counter-offer to yourself';
    }

    // Validate type-specific fields
    switch (params.type) {
      case CounterOfferType.cash:
        if (params.proposedCash == null) {
          return 'Proposed cash amount is required for cash counter-offers';
        }
        if (params.proposedCash! < 0) {
          return 'Cash amount cannot be negative';
        }
        break;

      case CounterOfferType.location:
        if (params.proposedMeetupLocation == null ||
            params.proposedMeetupLocation!.isEmpty) {
          return 'Meetup location is required for location counter-offers';
        }
        break;

      case CounterOfferType.time:
        if (params.proposedMeetupTime == null) {
          return 'Meetup time is required for time counter-offers';
        }
        if (params.proposedMeetupTime!.isBefore(DateTime.now())) {
          return 'Meetup time cannot be in the past';
        }
        break;

      case CounterOfferType.full:
        // Full counter-offer should have at least some changes
        if (params.proposedCash == null &&
            params.proposedMeetupLocation == null &&
            params.proposedMeetupTime == null) {
          return 'Full counter-offer must include at least one change';
        }
        break;

      case CounterOfferType.terms:
        if (params.message == null || params.message!.isEmpty) {
          return 'Message is required for terms counter-offers';
        }
        break;

      case CounterOfferType.itemSwap:
        // TODO: Validate item swap specific fields
        break;
    }

    return null;
  }

  /// Quick validation: Can user send counter-offer?
  bool canSendCounterOffer({
    required String userId,
    required NegotiationEntity negotiation,
  }) {
    // User must be part of negotiation
    if (userId != negotiation.initiatorId &&
        userId != negotiation.responderId) {
      return false;
    }

    // Negotiation must be active
    if (negotiation.status != NegotiationStatus.active) {
      return false;
    }

    // Cannot be expired
    if (negotiation.isExpired) {
      return false;
    }

    // It must be user's turn (not the current offerer)
    if (userId == negotiation.currentOfferer) {
      return false;
    }

    return true;
  }
}

/// Parameters for sending counter-offer
class SendCounterOfferParams {
  final String negotiationId;
  final String offerId; // Original trade offer
  final String offererId; // User making counter-offer
  final String targetUserId; // User receiving counter-offer
  final CounterOfferType type;

  // Counter-offer terms
  final double? proposedCash;
  final String? proposedPaymentDirection;
  final String? proposedMeetupLocation;
  final DateTime? proposedMeetupTime;
  final String? message;

  // Expiration
  final int? expirationHours; // Default: 48 hours

  SendCounterOfferParams({
    required this.negotiationId,
    required this.offerId,
    required this.offererId,
    required this.targetUserId,
    required this.type,
    this.proposedCash,
    this.proposedPaymentDirection,
    this.proposedMeetupLocation,
    this.proposedMeetupTime,
    this.message,
    this.expirationHours,
  });

  /// Create quick cash counter-offer
  factory SendCounterOfferParams.cash({
    required String negotiationId,
    required String offerId,
    required String offererId,
    required String targetUserId,
    required double amount,
    String? paymentDirection,
    String? message,
  }) {
    return SendCounterOfferParams(
      negotiationId: negotiationId,
      offerId: offerId,
      offererId: offererId,
      targetUserId: targetUserId,
      type: CounterOfferType.cash,
      proposedCash: amount,
      proposedPaymentDirection: paymentDirection,
      message: message,
    );
  }

  /// Create quick location counter-offer
  factory SendCounterOfferParams.location({
    required String negotiationId,
    required String offerId,
    required String offererId,
    required String targetUserId,
    required String location,
    String? message,
  }) {
    return SendCounterOfferParams(
      negotiationId: negotiationId,
      offerId: offerId,
      offererId: offererId,
      targetUserId: targetUserId,
      type: CounterOfferType.location,
      proposedMeetupLocation: location,
      message: message,
    );
  }

  /// Create quick time counter-offer
  factory SendCounterOfferParams.time({
    required String negotiationId,
    required String offerId,
    required String offererId,
    required String targetUserId,
    required DateTime meetupTime,
    String? message,
  }) {
    return SendCounterOfferParams(
      negotiationId: negotiationId,
      offerId: offerId,
      offererId: offererId,
      targetUserId: targetUserId,
      type: CounterOfferType.time,
      proposedMeetupTime: meetupTime,
      message: message,
    );
  }
}
