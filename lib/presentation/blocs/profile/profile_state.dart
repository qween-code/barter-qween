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
  final int itemCount;
  final int tradeCount;
  final double averageRating;
  final int ratingCount;

  const ProfileLoaded(
    this.user, {
    this.itemCount = 0,
    this.tradeCount = 0,
    this.averageRating = 0.0,
    this.ratingCount = 0,
  });

  // Create a copy with updated stats
  ProfileLoaded copyWithStats({
    required int itemCount,
    required int tradeCount,
    required double averageRating,
    required int ratingCount,
  }) {
    return ProfileLoaded(
      user,
      itemCount: itemCount,
      tradeCount: tradeCount,
      averageRating: averageRating,
      ratingCount: ratingCount,
    );
  }

  @override
  List<Object?> get props => [user, itemCount, tradeCount, averageRating, ratingCount];
}

/// Profile updated successfully
class ProfileUpdated extends ProfileState {
  final UserEntity user;
  final int itemCount;
  final int tradeCount;
  final double averageRating;
  final int ratingCount;

  const ProfileUpdated(
    this.user, {
    this.itemCount = 0,
    this.tradeCount = 0,
    this.averageRating = 0.0,
    this.ratingCount = 0,
  });

  @override
  List<Object?> get props => [user, itemCount, tradeCount, averageRating, ratingCount];
}

/// Avatar uploading
class AvatarUploading extends ProfileState {
  const AvatarUploading();
}

/// Avatar uploaded successfully
class AvatarUploaded extends ProfileState {
  final String avatarUrl;
  final UserEntity user;
  final int itemCount;
  final int tradeCount;
  final double averageRating;
  final int ratingCount;

  const AvatarUploaded({
    required this.avatarUrl,
    required this.user,
    this.itemCount = 0,
    this.tradeCount = 0,
    this.averageRating = 0.0,
    this.ratingCount = 0,
  });

  @override
  List<Object?> get props => [avatarUrl, user, itemCount, tradeCount, averageRating, ratingCount];
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

/// User statistics loaded (deprecated - stats now included in ProfileLoaded)
@Deprecated('Stats are now included in ProfileLoaded state')
class UserStatsLoaded extends ProfileState {
  final int itemCount;
  final int tradeCount;
  final double averageRating;
  final int ratingCount;

  const UserStatsLoaded({
    required this.itemCount,
    required this.tradeCount,
    required this.averageRating,
    required this.ratingCount,
  });

  @override
  List<Object?> get props => [itemCount, tradeCount, averageRating, ratingCount];
}
