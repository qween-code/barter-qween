import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../core/cache/cache_manager.dart';
import '../../../domain/usecases/profile/get_user_profile_usecase.dart';
import '../../../domain/usecases/profile/get_user_stats_usecase.dart';
import '../../../domain/usecases/profile/update_profile_usecase.dart';
import '../../../domain/usecases/profile/upload_avatar_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final GetUserStatsUseCase getUserStatsUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UploadAvatarUseCase uploadAvatarUseCase;
  final CacheManager _cacheManager = CacheManager();

  ProfileBloc({
    required this.getUserProfileUseCase,
    required this.getUserStatsUseCase,
    required this.updateProfileUseCase,
    required this.uploadAvatarUseCase,
  }) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<LoadUserStats>(_onLoadUserStats);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadAvatar>(_onUploadAvatar);
    on<ResetProfile>(_onResetProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    print('🔄 Loading profile for user: ${event.userId}');

    // Check cache first (cache-first strategy)
    final cachedUser = _cacheManager.getCachedUser(event.userId);
    if (cachedUser != null) {
      print('✅ Profile loaded from cache: ${cachedUser.displayName}');
      emit(ProfileLoaded(cachedUser));

      // Load stats in background
      add(LoadUserStats(event.userId));

      // Refresh data in background for next time
      _refreshProfileInBackground(event.userId);
      return;
    }

    // No cache, show loading
    emit(const ProfileLoading());

    final result = await getUserProfileUseCase(event.userId);

    result.fold(
      (failure) {
        print('❌ Profile load failed: ${failure.message}');
        emit(ProfileError(failure.message));
      },
      (user) {
        print('✅ Profile loaded successfully: ${user.displayName}');
        // Cache the user data
        _cacheManager.cacheUser(event.userId, user);
        emit(ProfileLoaded(user));
      },
    );
  }

  /// Refresh profile data in background without showing loading state
  Future<void> _refreshProfileInBackground(String userId) async {
    final result = await getUserProfileUseCase(userId);
    result.fold(
      (failure) => print('⚠️ Background refresh failed: ${failure.message}'),
      (user) {
        print('🔄 Profile refreshed in background');
        _cacheManager.cacheUser(userId, user);
      },
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await updateProfileUseCase(event.user);

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileUpdated(user)),
    );
  }

  Future<void> _onUploadAvatar(
    UploadAvatar event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const AvatarUploading());

    final result = await uploadAvatarUseCase(event.userId, event.imageFile);

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (avatarUrl) async {
        // Reload user profile to get updated avatar URL
        final userResult = await getUserProfileUseCase(event.userId);
        userResult.fold(
          (failure) => emit(ProfileError(failure.message)),
          (user) => emit(AvatarUploaded(avatarUrl: avatarUrl, user: user)),
        );
      },
    );
  }

  void _onResetProfile(
    ResetProfile event,
    Emitter<ProfileState> emit,
  ) {
    // Clear cache when resetting
    if (event.userId != null) {
      _cacheManager.clearUserCache(event.userId!);
    }
    emit(const ProfileInitial());
  }

  Future<void> _onLoadUserStats(
    LoadUserStats event,
    Emitter<ProfileState> emit,
  ) async {
    print('📊 Loading user stats for: ${event.userId}');

    // Check cache first
    final cachedStats = _cacheManager.getCachedProfileStats(event.userId);
    if (cachedStats != null) {
      print('✅ Stats loaded from cache');
      _emitStatsState(cachedStats, emit);

      // Refresh in background
      _refreshStatsInBackground(event.userId, emit);
      return;
    }

    final result = await getUserStatsUseCase(event.userId);

    result.fold(
      (failure) {
        print('❌ Stats load failed: ${failure.message}');
        // Don't emit error for stats, just log it
      },
      (stats) {
        // Cache the stats
        _cacheManager.cacheProfileStats(event.userId, stats);
        _emitStatsState(stats, emit);
      },
    );
  }

  void _emitStatsState(Map<String, dynamic> stats, Emitter<ProfileState> emit) {
    final itemCount = stats['itemCount'] as int? ?? 0;
    final tradeCount = stats['tradeCount'] as int? ?? 0;
    final averageRating = stats['averageRating'] as double? ?? 0.0;
    final ratingCount = stats['ratingCount'] as int? ?? 0;

    print('✅ Stats loaded: items=$itemCount, trades=$tradeCount');

    // Update the current ProfileLoaded state with stats
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWithStats(
        itemCount: itemCount,
        tradeCount: tradeCount,
        averageRating: averageRating,
        ratingCount: ratingCount,
      ));
    } else {
      // Fallback: emit deprecated UserStatsLoaded for compatibility
      emit(UserStatsLoaded(
        itemCount: itemCount,
        tradeCount: tradeCount,
        averageRating: averageRating,
        ratingCount: ratingCount,
      ));
    }
  }

  Future<void> _refreshStatsInBackground(String userId, Emitter<ProfileState> emit) async {
    final result = await getUserStatsUseCase(userId);
    result.fold(
      (failure) => print('⚠️ Background stats refresh failed: ${failure.message}'),
      (stats) {
        print('🔄 Stats refreshed in background');
        _cacheManager.cacheProfileStats(userId, stats);
        _emitStatsState(stats, emit);
      },
    );
  }
}
