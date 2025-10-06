import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../repositories/barter_match_repository.dart';
import '../../core/error/failures.dart';

@injectable
class DismissBarterMatchUsecase {
  final BarterMatchRepository _repository;

  DismissBarterMatchUsecase(this._repository);

  Future<Either<Failure, void>> call(DismissBarterMatchParams params) async {
    return await _repository.dismissBarterMatch(params.matchId);
  }
}

class DismissBarterMatchParams {
  final String matchId;

  DismissBarterMatchParams({required this.matchId});
}
