import 'package:dartz/dartz.dart';
import '../../entities/rating_entity.dart';
import '../../repositories/rating_repository.dart';
import '../../../core/error/failures.dart';

import 'package:injectable/injectable.dart';

@injectable
class CreateRatingUseCase {
  final RatingRepository repository;
  CreateRatingUseCase(this.repository);

  Future<Either<Failure, RatingEntity>> call({
    required String fromUserId,
    required String toUserId,
    required String tradeId,
    required int rating,
    String? comment,
  }) => repository.createRating(
        fromUserId: fromUserId,
        toUserId: toUserId,
        tradeId: tradeId,
        rating: rating,
        comment: comment,
      );
}