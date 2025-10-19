import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  final String userId;
  final String? viewerId;

  const LoadProfile(this.userId, {this.viewerId});

  @override
  List<Object?> get props => [userId, viewerId];
}

class UpdateProfile extends ProfileEvent {
  final UserEntity user;

  const UpdateProfile(this.user);

  @override
  List<Object?> get props => [user];
}

class LoadUserStats extends ProfileEvent {
  final String userId;

  const LoadUserStats(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ResetProfile extends ProfileEvent {
  const ResetProfile();
}

class UploadAvatar extends ProfileEvent {
  final File imageFile;
  final String userId;

  const UploadAvatar({required this.imageFile, required this.userId});

  @override
  List<Object?> get props => [imageFile, userId];
}

class FollowUserProfile extends ProfileEvent {
  final String currentUserId;
  final String targetUserId;

  const FollowUserProfile({
    required this.currentUserId,
    required this.targetUserId,
  });

  @override
  List<Object?> get props => [currentUserId, targetUserId];
}

class UnfollowUserProfile extends ProfileEvent {
  final String currentUserId;
  final String targetUserId;

  const UnfollowUserProfile({
    required this.currentUserId,
    required this.targetUserId,
  });

  @override
  List<Object?> get props => [currentUserId, targetUserId];
}
