import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading state
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Profile loaded successfully
class ProfileLoaded extends ProfileState {
  final UserEntity user;

  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

/// Profile updated successfully
class ProfileUpdated extends ProfileState {
  final UserEntity user;

  const ProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Avatar uploading
class AvatarUploading extends ProfileState {
  const AvatarUploading();
}

/// Avatar uploaded successfully
class AvatarUploaded extends ProfileState {
  final String avatarUrl;
  final UserEntity user;

  const AvatarUploaded({
    required this.avatarUrl,
    required this.user,
  });

  @override
  List<Object?> get props => [avatarUrl, user];
}

/// Avatar deleted successfully
class AvatarDeleted extends ProfileState {
  final UserEntity user;

  const AvatarDeleted(this.user);

  @override
  List<Object?> get props => [user];
}

/// Error state
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
