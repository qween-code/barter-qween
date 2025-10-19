import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../repositories/profile_repository.dart';

@injectable
class FollowUserUseCase {
  final ProfileRepository repository;

  FollowUserUseCase(this.repository);

  Future<Either<Failure, void>> call(
    String currentUserId,
    String targetUserId,
  ) {
    return repository.followUser(currentUserId, targetUserId);
  }
}
