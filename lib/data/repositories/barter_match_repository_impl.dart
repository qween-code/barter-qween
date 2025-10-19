import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/barter_match_entity.dart';
import '../../domain/repositories/barter_match_repository.dart';
import '../models/barter_match_model.dart';

/// Repository implementation for barter match operations
@LazySingleton(as: BarterMatchRepository)
class BarterMatchRepositoryImpl implements BarterMatchRepository {
  final FirebaseFirestore _firestore;

  BarterMatchRepositoryImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<Either<Failure, List<BarterMatchEntity>>> findMatches(
    String itemId, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('barter_matches')
          .where('sourceItemId', isEqualTo: itemId)
          .where('isDismissed', isEqualTo: false)
          .orderBy('matchScore', descending: true)
          .limit(limit)
          .get();

      final matches = snapshot.docs
          .map((doc) => BarterMatchModel.fromFirestore(doc).toEntity())
          .toList();

      return Right(matches);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BarterMatchEntity>> getMatch(String matchId) async {
    try {
      final doc = await _firestore
          .collection('barter_matches')
          .doc(matchId)
          .get();

      if (!doc.exists) {
        return Left(NotFoundFailure('Match not found'));
      }

      final match = BarterMatchModel.fromFirestore(doc).toEntity();
      return Right(match);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BarterMatchEntity>> createMatch(
    BarterMatchEntity match,
  ) async {
    try {
      final model = BarterMatchModel.fromEntity(match);
      final docRef = await _firestore
          .collection('barter_matches')
          .add(model.toFirestore());

      // Get created document
      final doc = await docRef.get();
      final createdMatch = BarterMatchModel.fromFirestore(doc).toEntity();

      return Right(createdMatch);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BarterMatchEntity>> updateMatchStatus(
    String matchId,
    bool isSeen,
    bool isDismissed,
  ) async {
    try {
      final updateData = <String, dynamic>{
        'isSeen': isSeen,
        'isDismissed': isDismissed,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isSeen) {
        updateData['seenAt'] = FieldValue.serverTimestamp();
      }
      if (isDismissed) {
        updateData['dismissedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore
          .collection('barter_matches')
          .doc(matchId)
          .update(updateData);

      // Get updated document
      return await getMatch(matchId);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> incrementViewCount(String matchId) async {
    try {
      await _firestore.collection('barter_matches').doc(matchId).update({
        'viewCount': FieldValue.increment(1),
      });

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsOffered(
    String matchId,
    String offerId,
  ) async {
    try {
      await _firestore.collection('barter_matches').doc(matchId).update({
        'wasOffered': true,
        'offerId': offerId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BarterMatchEntity>>> getHighQualityMatches(
    String itemId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('barter_matches')
          .where('sourceItemId', isEqualTo: itemId)
          .where('isDismissed', isEqualTo: false)
          .where('matchScore', isGreaterThanOrEqualTo: 80.0)
          .orderBy('matchScore', descending: true)
          .limit(10)
          .get();

      final matches = snapshot.docs
          .map((doc) => BarterMatchModel.fromFirestore(doc).toEntity())
          .toList();

      return Right(matches);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMatch(String matchId) async {
    try {
      await _firestore.collection('barter_matches').doc(matchId).delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BarterMatchEntity>>> getBarterMatches(
    String itemId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('barter_matches')
          .where('sourceItemId', isEqualTo: itemId)
          .orderBy('matchScore', descending: true)
          .limit(20)
          .get();

      final matches = snapshot.docs
          .map((doc) => BarterMatchEntityExtension.fromJson(doc.data()))
          .toList();

      return Right(matches);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> dismissBarterMatch(String matchId) async {
    try {
      await _firestore.collection('barter_matches').doc(matchId).update({
        'isDismissed': true,
        'dismissedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
