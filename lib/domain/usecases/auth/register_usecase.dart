import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

@lazySingleton
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (email.isEmpty || password.isEmpty || displayName.isEmpty) {
      return const Left(ValidationFailure('All fields are required'));
    }
    if (password.length < 6) {
      return const Left(ValidationFailure('Password must be at least 6 characters'));
    }
    return await repository.registerWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
