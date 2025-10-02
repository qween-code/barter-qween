import 'package:dartz/dartz.dart';
import '../../entities/rating_entity.dart';
import '../../repositories/rating_repository.dart';
import '../../../core/error/failures.dart';

import 'package:injectable/injectable.dart';

@injectable
class GetUserRatingsUseCase {
  final RatingRepository repository;
  GetUserRatingsUseCase(this.repository);

  Future<Either<Failure, List<RatingEntity>>> call(String userId) => repository.getUserRatings(userId);
}