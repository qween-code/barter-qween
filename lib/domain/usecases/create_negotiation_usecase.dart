import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../entities/negotiation_entity.dart';
import '../entities/trade_offer_entity.dart';

/// Use case for creating a negotiation thread
///
/// Starts a negotiation when offer recipient wants to negotiate terms
/// instead of accepting/rejecting outright
@lazySingleton
class CreateNegotiationUsecase {
  CreateNegotiationUsecase();

  /// Execute the use case
  ///
  /// Creates a negotiation thread for a trade offer
  Future<Either<Failure, NegotiationEntity>> call(
    CreateNegotiationParams params,
  ) async {
    try {
      // Validate params
      final validationResult = _validateParams(params);
      if (validationResult != null) {
        return Left(ValidationFailure(validationResult));
      }

      // TODO: Verify trade offer exists and is in correct state
      // TODO: Check that negotiation doesn't already exist

      final now = DateTime.now();
      final negotiation = NegotiationEntity(
        id: '', // Firestore will generate
        tradeOfferId: params.tradeOfferId,
        initiatorId: params.initiatorId,
        responderId: params.responderId,
        sourceItemId: '', // TODO: Get from trade offer
        targetItemId: '', // TODO: Get from trade offer
        receiverId: params.responderId,
        lastActionBy: params.initiatorId,
        lastCounterOffer: null,
        counterOffers: const [],
        status: NegotiationStatus.active,
        roundCount: 0,
        currentOfferer: params.initiatorId, // Initiator starts
        currentCashOffer: params.initialCashOffer,
        currentPaymentDirection: params.initialPaymentDirection,
        currentMeetupLocation: params.initialMeetupLocation,
        currentMeetupTime: params.initialMeetupTime,
        currentNotes: params.initialMessage,
        rounds: const [],
        totalMessages: 0,
        expiresAt: params.expirationDays != null
            ? now.add(Duration(days: params.expirationDays!))
            : now.add(const Duration(days: 7)), // Default 7 days
        createdAt: now,
        updatedAt: now,
        lastActivityAt: now,
      );

      // TODO: Save to repository
      // TODO: Update trade offer status to 'negotiating'
      // TODO: Send notification to responder
      // TODO: Create first negotiation round

      return Right(negotiation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Validate negotiation parameters
  String? _validateParams(CreateNegotiationParams params) {
    if (params.tradeOfferId.isEmpty) {
      return 'Trade offer ID is required';
    }
    if (params.initiatorId.isEmpty) {
      return 'Initiator ID is required';
    }
    if (params.responderId.isEmpty) {
      return 'Responder ID is required';
    }
    if (params.initiatorId == params.responderId) {
      return 'Cannot negotiate with yourself';
    }

    // Validate meetup time if provided
    if (params.initialMeetupTime != null &&
        params.initialMeetupTime!.isBefore(DateTime.now())) {
      return 'Meetup time cannot be in the past';
    }

    // Validate cash offer if provided
    if (params.initialCashOffer != null && params.initialCashOffer! < 0) {
      return 'Cash offer cannot be negative';
    }

    // Validate expiration
    if (params.expirationDays != null && params.expirationDays! < 1) {
      return 'Expiration must be at least 1 day';
    }

    return null;
  }

  /// Quick validation: Can user start negotiation for this offer?
  bool canStartNegotiation({
    required String userId,
    required TradeOfferEntity offer,
  }) {
    // User must be the recipient (not sender)
    if (userId != offer.toUserId) {
      return false;
    }

    // Offer must be pending
    if (offer.status != TradeStatus.pending) {
      return false;
    }

    // TODO: Check if negotiation already exists

    return true;
  }

  /// Generate initial negotiation message
  String generateInitialMessage({
    required String initiatorName,
    String? reason,
  }) {
    if (reason != null && reason.isNotEmpty) {
      return '$initiatorName takas şartlarını görüşmek istiyor: $reason';
    }
    return '$initiatorName takas şartlarını görüşmek istiyor.';
  }
}

/// Parameters for creating negotiation
class CreateNegotiationParams {
  final String tradeOfferId; // Original offer to negotiate
  final String
  initiatorId; // User starting negotiation (usually offer recipient)
  final String responderId; // User responding (usually offer sender)

  // Initial negotiation terms (optional - can start with original offer terms)
  final double? initialCashOffer;
  final String? initialPaymentDirection;
  final String? initialMeetupLocation;
  final DateTime? initialMeetupTime;
  final String? initialMessage;

  // Settings
  final int? expirationDays; // Default: 7 days

  CreateNegotiationParams({
    required this.tradeOfferId,
    required this.initiatorId,
    required this.responderId,
    this.initialCashOffer,
    this.initialPaymentDirection,
    this.initialMeetupLocation,
    this.initialMeetupTime,
    this.initialMessage,
    this.expirationDays,
  });

  /// Create with just offer ID and users (use original offer terms)
  factory CreateNegotiationParams.fromOffer({
    required String tradeOfferId,
    required String initiatorId,
    required String responderId,
    String? message,
  }) {
    return CreateNegotiationParams(
      tradeOfferId: tradeOfferId,
      initiatorId: initiatorId,
      responderId: responderId,
      initialMessage: message,
    );
  }

  /// Create with cash counter-proposal
  factory CreateNegotiationParams.withCashProposal({
    required String tradeOfferId,
    required String initiatorId,
    required String responderId,
    required double cashAmount,
    required String paymentDirection,
    String? message,
  }) {
    return CreateNegotiationParams(
      tradeOfferId: tradeOfferId,
      initiatorId: initiatorId,
      responderId: responderId,
      initialCashOffer: cashAmount,
      initialPaymentDirection: paymentDirection,
      initialMessage: message,
    );
  }

  /// Create with location/time proposal
  factory CreateNegotiationParams.withMeetupProposal({
    required String tradeOfferId,
    required String initiatorId,
    required String responderId,
    String? location,
    DateTime? meetupTime,
    String? message,
  }) {
    return CreateNegotiationParams(
      tradeOfferId: tradeOfferId,
      initiatorId: initiatorId,
      responderId: responderId,
      initialMeetupLocation: location,
      initialMeetupTime: meetupTime,
      initialMessage: message,
    );
  }
}
