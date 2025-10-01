import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/profile_repository.dart';

@injectable
class UploadAvatarUseCase {
  final ProfileRepository repository;

  UploadAvatarUseCase(this.repository);

  Future<Either<Failure, String>> call(String userId, File imageFile) async {
    return await repository.uploadAvatar(userId, imageFile);
  }
}
