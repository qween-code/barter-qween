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

  const LoadProfile(this.userId);

  @override
  List<Object?> get props => [userId];
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

  const UploadAvatar({
    required this.imageFile,
    required this.userId,
  });

  @override
  List<Object?> get props => [imageFile, userId];
}