import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/negotiation_entity.dart';
import '../entities/counter_offer_entity.dart';

/// Repository interface for negotiation operations
abstract class NegotiationRepository {
  /// Create a new negotiation
  Future<Either<Failure, NegotiationEntity>> createNegotiation(
    NegotiationEntity negotiation,
  );

  /// Get negotiation by ID
  Future<Either<Failure, NegotiationEntity>> getNegotiation(
    String negotiationId,
  );

  /// Get all negotiations for a user
  Future<Either<Failure, List<NegotiationEntity>>> getUserNegotiations(
    String userId,
  );

  /// Update negotiation
  Future<Either<Failure, NegotiationEntity>> updateNegotiation(
    NegotiationEntity negotiation,
  );

  /// Accept negotiation (agreement reached)
  Future<Either<Failure, NegotiationEntity>> acceptNegotiation(
    String negotiationId,
    String userId,
  );

  /// Reject negotiation (end negotiation)
  Future<Either<Failure, NegotiationEntity>> rejectNegotiation(
    String negotiationId,
    String userId,
    String reason,
  );

  /// Send counter-offer
  Future<Either<Failure, CounterOfferEntity>> sendCounterOffer(
    CounterOfferEntity counterOffer,
  );

  /// Get counter-offer by ID
  Future<Either<Failure, CounterOfferEntity>> getCounterOffer(
    String counterOfferId,
  );

  /// Get all counter-offers for a negotiation
  Future<Either<Failure, List<CounterOfferEntity>>> getNegotiationCounterOffers(
    String negotiationId,
  );

  /// Accept a counter-offer
  Future<Either<Failure, CounterOfferEntity>> acceptCounterOffer(
    String counterOfferId,
    String userId,
  );

  /// Reject a counter-offer
  Future<Either<Failure, CounterOfferEntity>> rejectCounterOffer(
    String counterOfferId,
    String userId,
    String? reason,
  );
}
