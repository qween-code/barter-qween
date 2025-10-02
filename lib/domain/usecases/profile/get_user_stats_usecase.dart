import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/profile_repository.dart';

@injectable
class GetUserStatsUseCase {
  final ProfileRepository repository;

  GetUserStatsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    return await repository.getUserStats(userId);
  }
}
