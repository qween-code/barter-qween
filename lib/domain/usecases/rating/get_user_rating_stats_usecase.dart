import 'package:dartz/dartz.dart';
import '../../entities/rating_entity.dart';
import '../../repositories/rating_repository.dart';
import '../../../core/error/failures.dart';

import 'package:injectable/injectable.dart';

@injectable
class GetUserRatingStatsUseCase {
  final RatingRepository repository;
  GetUserRatingStatsUseCase(this.repository);

  Future<Either<Failure, UserRatingStats>> call(String userId) => repository.getUserRatingStats(userId);
}