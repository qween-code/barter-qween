import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/negotiation_entity.dart';
import '../../domain/entities/counter_offer_entity.dart';
import '../../domain/repositories/negotiation_repository.dart';
import '../models/negotiation_model.dart';
import '../models/counter_offer_model.dart';

/// Repository implementation for negotiation operations
@LazySingleton(as: NegotiationRepository)
class NegotiationRepositoryImpl implements NegotiationRepository {
  final FirebaseFirestore _firestore;

  NegotiationRepositoryImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<Either<Failure, NegotiationEntity>> createNegotiation(
    NegotiationEntity negotiation,
  ) async {
    try {
      final model = NegotiationModel.fromEntity(negotiation);
      final docRef = await _firestore
          .collection('negotiations')
          .add(model.toFirestore());

      final doc = await docRef.get();
      final created = NegotiationModel.fromFirestore(doc).toEntity();

      return Right(created);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NegotiationEntity>> getNegotiation(
    String negotiationId,
  ) async {
    try {
      final doc = await _firestore
          .collection('negotiations')
          .doc(negotiationId)
          .get();

      if (!doc.exists) {
        return Left(NotFoundFailure('Negotiation not found'));
      }

      final negotiation = NegotiationModel.fromFirestore(doc).toEntity();
      return Right(negotiation);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NegotiationEntity>>> getUserNegotiations(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('negotiations')
          .where('status', isEqualTo: 'active')
          .orderBy('lastActivityAt', descending: true)
          .get();

      final negotiations = snapshot.docs
          .map((doc) => NegotiationModel.fromFirestore(doc).toEntity())
          .where((n) => n.initiatorId == userId || n.responderId == userId)
          .toList();

      return Right(negotiations);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NegotiationEntity>> updateNegotiation(
    NegotiationEntity negotiation,
  ) async {
    try {
      final model = NegotiationModel.fromEntity(negotiation);
      await _firestore
          .collection('negotiations')
          .doc(negotiation.id)
          .update(model.toFirestore());

      return await getNegotiation(negotiation.id);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CounterOfferEntity>> sendCounterOffer(
    CounterOfferEntity counterOffer,
  ) async {
    try {
      final model = CounterOfferModel.fromEntity(counterOffer);
      final docRef = await _firestore
          .collection('counter_offers')
          .add(model.toFirestore());

      final doc = await docRef.get();
      final created = CounterOfferModel.fromFirestore(doc).toEntity();

      return Right(created);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CounterOfferEntity>> getCounterOffer(
    String counterOfferId,
  ) async {
    try {
      final doc = await _firestore
          .collection('counter_offers')
          .doc(counterOfferId)
          .get();

      if (!doc.exists) {
        return Left(NotFoundFailure('Counter-offer not found'));
      }

      final counterOffer = CounterOfferModel.fromFirestore(doc).toEntity();
      return Right(counterOffer);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CounterOfferEntity>>> getNegotiationCounterOffers(
    String negotiationId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('counter_offers')
          .where('negotiationId', isEqualTo: negotiationId)
          .orderBy('createdAt', descending: false)
          .get();

      final counterOffers = snapshot.docs
          .map((doc) => CounterOfferModel.fromFirestore(doc).toEntity())
          .toList();

      return Right(counterOffers);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CounterOfferEntity>> acceptCounterOffer(
    String counterOfferId,
    String userId,
  ) async {
    try {
      await _firestore.collection('counter_offers').doc(counterOfferId).update({
        'status': 'accepted',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      return await getCounterOffer(counterOfferId);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CounterOfferEntity>> rejectCounterOffer(
    String counterOfferId,
    String userId,
    String? reason,
  ) async {
    try {
      await _firestore.collection('counter_offers').doc(counterOfferId).update({
        'status': 'rejected',
        'respondedAt': FieldValue.serverTimestamp(),
        'responseMessage': reason,
      });

      return await getCounterOffer(counterOfferId);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NegotiationEntity>> acceptNegotiation(
    String negotiationId,
    String userId,
  ) async {
    try {
      await _firestore.collection('negotiations').doc(negotiationId).update({
        'status': 'agreed',
        'agreedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return await getNegotiation(negotiationId);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NegotiationEntity>> rejectNegotiation(
    String negotiationId,
    String userId,
    String reason,
  ) async {
    try {
      await _firestore.collection('negotiations').doc(negotiationId).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectedBy': userId,
        'rejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return await getNegotiation(negotiationId);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
