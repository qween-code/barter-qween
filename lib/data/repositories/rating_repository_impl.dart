import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/rating_entity.dart';
import '../../domain/repositories/rating_repository.dart';
import '../datasources/remote/rating_remote_datasource.dart';

@LazySingleton(as: RatingRepository)
class RatingRepositoryImpl implements RatingRepository {
  final RatingRemoteDataSource _remote;
  RatingRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, RatingEntity>> createRating({
    required String fromUserId,
    required String toUserId,
    required String tradeId,
    required int rating,
    String? comment,
  }) async {
    try {
      final r = await _remote.create(
        fromUserId: fromUserId,
        toUserId: toUserId,
        tradeId: tradeId,
        rating: rating,
        comment: comment,
      );
      return Right(r);
    } catch (e) {
      return Left(UnknownFailure('Failed to create rating: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RatingEntity>>> getUserRatings(String userId) async {
    try {
      final list = await _remote.getUserRatings(userId);
      return Right(list);
    } catch (e) {
      return Left(UnknownFailure('Failed to load ratings: $e'));
    }
  }

  @override
  Future<Either<Failure, UserRatingStats>> getUserRatingStats(String userId) async {
    try {
      final s = await _remote.getUserRatingStats(userId);
      return Right(s);
    } catch (e) {
      return Left(UnknownFailure('Failed to load rating stats: $e'));
    }
  }
}