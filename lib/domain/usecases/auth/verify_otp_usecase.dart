import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';

@injectable
class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String verificationId,
    required String smsCode,
  }) async {
    return await repository.verifyOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }
}
