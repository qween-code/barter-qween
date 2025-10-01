import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';

@injectable
class PhoneSignInUseCase {
  final AuthRepository repository;

  PhoneSignInUseCase(this.repository);

  Future<Either<Failure, String>> call(String phoneNumber) async {
    return await repository.signInWithPhone(phoneNumber);
  }
}
