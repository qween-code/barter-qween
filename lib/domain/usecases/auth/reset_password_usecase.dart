import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';

@injectable
class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) async {
    return await repository.resetPassword(email);
  }
}
