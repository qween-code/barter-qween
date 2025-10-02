import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/rating_entity.dart';

abstract class RatingRepository {
  Future<Either<Failure, RatingEntity>> createRating({
    required String fromUserId,
    required String toUserId,
    required String tradeId,
    required int rating,
    String? comment,
  });

  Future<Either<Failure, List<RatingEntity>>> getUserRatings(String userId);

  Future<Either<Failure, UserRatingStats>> getUserRatingStats(String userId);
}