import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/profile/get_user_profile_usecase.dart';
import '../../../domain/usecases/profile/get_user_stats_usecase.dart';
import '../../../domain/usecases/profile/follow_user_usecase.dart';
import '../../../domain/usecases/profile/unfollow_user_usecase.dart';
import '../../../domain/usecases/profile/check_follow_status_usecase.dart';
import '../../../domain/usecases/profile/update_profile_usecase.dart';
import '../../../domain/usecases/profile/upload_avatar_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc()
    : _getUserProfile = getIt<GetUserProfileUseCase>(),
      _getUserStats = getIt<GetUserStatsUseCase>(),
      _followUser = getIt<FollowUserUseCase>(),
      _unfollowUser = getIt<UnfollowUserUseCase>(),
      _checkFollowStatus = getIt<CheckFollowStatusUseCase>(),
      _updateProfile = getIt<UpdateProfileUseCase>(),
      _uploadAvatar = getIt<UploadAvatarUseCase>(),
      super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<LoadUserStats>(_onLoadUserStats);
    on<UploadAvatar>(_onUploadAvatar);
    on<ResetProfile>(_onResetProfile);
    on<FollowUserProfile>(_onFollowUserProfile);
    on<UnfollowUserProfile>(_onUnfollowUserProfile);
  }

  final GetUserProfileUseCase _getUserProfile;
  final GetUserStatsUseCase _getUserStats;
  final FollowUserUseCase _followUser;
  final UnfollowUserUseCase _unfollowUser;
  final CheckFollowStatusUseCase _checkFollowStatus;
  final UpdateProfileUseCase _updateProfile;
  final UploadAvatarUseCase _uploadAvatar;

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final profileResult = await _getUserProfile(event.userId);

    await profileResult.fold(
      (failure) async {
        emit(ProfileError(message: failure.message));
      },
      (user) async {
        final statsResult = await _getUserStats(event.userId);
        final stats = statsResult.fold<Map<String, dynamic>>(
          (_) => const {},
          (value) => value,
        );

        final social = user.social ?? const <String, dynamic>{};
        final followersCount = _asInt(
          social['followersCount'] ?? social['followers'],
        );
        final followingCount = _asInt(
          social['followingCount'] ?? social['following'],
        );

        var isFollowing = false;
        final viewerId = event.viewerId;
        if (viewerId != null && viewerId.isNotEmpty && viewerId != user.uid) {
          final followResult = await _checkFollowStatus(viewerId, event.userId);
          isFollowing = followResult.fold((_) => false, (value) => value);
        }

        emit(
          ProfileLoaded(
            user: user,
            itemCount: _asInt(stats['itemCount']),
            tradeCount: _asInt(stats['tradeCount']),
            averageRating: _asDouble(stats['averageRating']),
            ratingCount: _asInt(stats['ratingCount']),
            followersCount: followersCount,
            followingCount: followingCount,
            isFollowing: isFollowing,
          ),
        );
      },
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await _updateProfile(event.user);

    await result.fold(
      (failure) async {
        emit(ProfileError(message: failure.message));
      },
      (updatedUser) async {
        final snapshot = _currentSnapshot();
        emit(
          ProfileUpdated(
            user: updatedUser,
            itemCount: snapshot.itemCount,
            tradeCount: snapshot.tradeCount,
            averageRating: snapshot.averageRating,
            ratingCount: snapshot.ratingCount,
            followersCount: snapshot.followersCount,
            followingCount: snapshot.followingCount,
            isFollowing: snapshot.isFollowing,
          ),
        );
      },
    );
  }

  Future<void> _onLoadUserStats(
    LoadUserStats event,
    Emitter<ProfileState> emit,
  ) async {
    final statsResult = await _getUserStats(event.userId);
    statsResult.fold(
      (failure) {
        if (state is! ProfileLoaded && state is! ProfileUpdated) {
          emit(ProfileError(message: failure.message));
        }
      },
      (stats) {
        final snapshot = _currentSnapshot();
        final user = snapshot.user;
        if (user != null) {
          emit(
            ProfileLoaded(
              user: user,
              itemCount: _asInt(stats['itemCount']),
              tradeCount: _asInt(stats['tradeCount']),
              averageRating: _asDouble(stats['averageRating']),
              ratingCount: _asInt(stats['ratingCount']),
              followersCount: snapshot.followersCount,
              followingCount: snapshot.followingCount,
              isFollowing: snapshot.isFollowing,
            ),
          );
        } else {
          emit(
            UserStatsLoaded(
              itemCount: _asInt(stats['itemCount']),
              tradeCount: _asInt(stats['tradeCount']),
              averageRating: _asDouble(stats['averageRating']),
              ratingCount: _asInt(stats['ratingCount']),
            ),
          );
        }
      },
    );
  }

  Future<void> _onFollowUserProfile(
    FollowUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final snapshot = _currentSnapshot();
    final user = snapshot.user;
    if (user == null || snapshot.isFollowing) {
      return;
    }

    final result = await _followUser(event.currentUserId, event.targetUserId);

    await result.fold(
      (failure) async {
        print('❌ Follow user failed: ${failure.message}');
      },
      (_) async {
        emit(
          ProfileUpdated(
            user: user,
            itemCount: snapshot.itemCount,
            tradeCount: snapshot.tradeCount,
            averageRating: snapshot.averageRating,
            ratingCount: snapshot.ratingCount,
            followersCount: snapshot.followersCount + 1,
            followingCount: snapshot.followingCount,
            isFollowing: true,
          ),
        );
      },
    );
  }

  Future<void> _onUnfollowUserProfile(
    UnfollowUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final snapshot = _currentSnapshot();
    final user = snapshot.user;
    if (user == null || !snapshot.isFollowing) {
      return;
    }

    final result = await _unfollowUser(event.currentUserId, event.targetUserId);

    await result.fold(
      (failure) async {
        print('❌ Unfollow user failed: ${failure.message}');
      },
      (_) async {
        emit(
          ProfileUpdated(
            user: user,
            itemCount: snapshot.itemCount,
            tradeCount: snapshot.tradeCount,
            averageRating: snapshot.averageRating,
            ratingCount: snapshot.ratingCount,
            followersCount: snapshot.followersCount > 0
                ? snapshot.followersCount - 1
                : 0,
            followingCount: snapshot.followingCount,
            isFollowing: false,
          ),
        );
      },
    );
  }

  Future<void> _onUploadAvatar(
    UploadAvatar event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await _uploadAvatar(event.userId, event.imageFile);

    result.fold((failure) => emit(ProfileError(message: failure.message)), (
      url,
    ) {
      final snapshot = _currentSnapshot();
      final updatedUser = snapshot.user?.copyWith(photoUrl: url);
      if (updatedUser != null) {
        emit(
          ProfileUpdated(
            user: updatedUser,
            itemCount: snapshot.itemCount,
            tradeCount: snapshot.tradeCount,
            averageRating: snapshot.averageRating,
            ratingCount: snapshot.ratingCount,
            followersCount: snapshot.followersCount,
            followingCount: snapshot.followingCount,
            isFollowing: snapshot.isFollowing,
          ),
        );
      } else {
        emit(AvatarUploaded(avatarUrl: url));
      }
    });
  }

  void _onResetProfile(ResetProfile event, Emitter<ProfileState> emit) {
    emit(const ProfileInitial());
  }

  _ProfileSnapshot _currentSnapshot() {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      return _ProfileSnapshot(
        user: currentState.user,
        itemCount: currentState.itemCount,
        tradeCount: currentState.tradeCount,
        averageRating: currentState.averageRating,
        ratingCount: currentState.ratingCount,
        followersCount: currentState.followersCount,
        followingCount: currentState.followingCount,
        isFollowing: currentState.isFollowing,
      );
    }
    if (currentState is ProfileUpdated) {
      return _ProfileSnapshot(
        user: currentState.user,
        itemCount: currentState.itemCount,
        tradeCount: currentState.tradeCount,
        averageRating: currentState.averageRating,
        ratingCount: currentState.ratingCount,
        followersCount: currentState.followersCount,
        followingCount: currentState.followingCount,
        isFollowing: currentState.isFollowing,
      );
    }
    return const _ProfileSnapshot();
  }

  int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is Iterable) return value.length;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0;
  }

  double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0;
  }
}

class _ProfileSnapshot {
  final UserEntity? user;
  final int itemCount;
  final int tradeCount;
  final double averageRating;
  final int ratingCount;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;

  const _ProfileSnapshot({
    this.user,
    this.itemCount = 0,
    this.tradeCount = 0,
    this.averageRating = 0,
    this.ratingCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
  });
}
