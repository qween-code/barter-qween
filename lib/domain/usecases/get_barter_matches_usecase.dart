import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/barter_match_entity.dart';
import '../repositories/barter_match_repository.dart';
import '../../core/error/failures.dart';

@injectable
class GetBarterMatchesUsecase {
  final BarterMatchRepository _repository;

  GetBarterMatchesUsecase(this._repository);

  Future<Either<Failure, List<BarterMatchEntity>>> call(
    GetBarterMatchesParams params,
  ) async {
    return await _repository.getBarterMatches(params.itemId);
  }
}

class GetBarterMatchesParams {
  final String itemId;

  GetBarterMatchesParams({required this.itemId});
}
