import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class ProfileRepository {
  /// Get user profile by ID
  Future<Either<Failure, UserEntity>> getUserProfile(String userId);
  
  /// Update user profile
  Future<Either<Failure, UserEntity>> updateProfile(UserEntity user);
  
  /// Upload avatar image and get download URL
  Future<Either<Failure, String>> uploadAvatar(String userId, File imageFile);
  
  /// Delete avatar
  Future<Either<Failure, void>> deleteAvatar(String userId);
}
