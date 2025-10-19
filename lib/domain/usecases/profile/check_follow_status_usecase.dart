import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../repositories/profile_repository.dart';

@injectable
class CheckFollowStatusUseCase {
  final ProfileRepository repository;

  CheckFollowStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call(
    String currentUserId,
    String targetUserId,
  ) {
    return repository.isFollowing(currentUserId, targetUserId);
  }
}
