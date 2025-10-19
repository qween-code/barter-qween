import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProfileLoaded extends ProfileState {
  final UserEntity user;
  final int itemCount;
  final int tradeCount;
  final double averageRating;
  final int ratingCount;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;

  const ProfileLoaded({
    required this.user,
    this.itemCount = 0,
    this.tradeCount = 0,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
  });

  @override
  List<Object?> get props => [
    user,
    itemCount,
    tradeCount,
    averageRating,
    ratingCount,
    followersCount,
    followingCount,
    isFollowing,
  ];
}

class ProfileUpdated extends ProfileState {
  final UserEntity user;
  final int itemCount;
  final int tradeCount;
  final double averageRating;
  final int ratingCount;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;

  const ProfileUpdated({
    required this.user,
    this.itemCount = 0,
    this.tradeCount = 0,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
  });

  @override
  List<Object?> get props => [
    user,
    itemCount,
    tradeCount,
    averageRating,
    ratingCount,
    followersCount,
    followingCount,
    isFollowing,
  ];
}

// Avatar uploaded state for profile picture updates
class AvatarUploaded extends ProfileState {
  final String avatarUrl;

  const AvatarUploaded({required this.avatarUrl});

  @override
  List<Object?> get props => [avatarUrl];
}

// User stats loaded state
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
  List<Object?> get props => [
    itemCount,
    tradeCount,
    averageRating,
    ratingCount,
  ];
}
