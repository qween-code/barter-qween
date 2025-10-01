import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load user profile
class LoadProfile extends ProfileEvent {
  final String userId;

  const LoadProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Update user profile
class UpdateProfile extends ProfileEvent {
  final UserEntity user;

  const UpdateProfile(this.user);

  @override
  List<Object?> get props => [user];
}

/// Upload avatar
class UploadAvatar extends ProfileEvent {
  final String userId;
  final File imageFile;

  const UploadAvatar({
    required this.userId,
    required this.imageFile,
  });

  @override
  List<Object?> get props => [userId, imageFile];
}

/// Delete avatar
class DeleteAvatar extends ProfileEvent {
  final String userId;

  const DeleteAvatar(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Reset profile state
class ResetProfile extends ProfileEvent {
  const ResetProfile();
}
