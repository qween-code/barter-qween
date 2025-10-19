import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
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

  /// Follow another user
  Future<Either<Failure, void>> followUser(
    String currentUserId,
    String targetUserId,
  );

  /// Unfollow a user
  Future<Either<Failure, void>> unfollowUser(
    String currentUserId,
    String targetUserId,
  );

  /// Check if current user follows the target user
  Future<Either<Failure, bool>> isFollowing(
    String currentUserId,
    String targetUserId,
  );

  /// Get user statistics (item count, trade count, average rating)
  Future<Either<Failure, Map<String, dynamic>>> getUserStats(String userId);
}
