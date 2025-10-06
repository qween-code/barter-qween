// 🎮 GAMIFICATION CUBIT
// State management for coins, achievements, streaks

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/gamification_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// STATE
// ═══════════════════════════════════════════════════════════════════════════

abstract class GamificationState extends Equatable {
  const GamificationState();

  @override
  List<Object?> get props => [];
}

class GamificationInitial extends GamificationState {}

class GamificationLoading extends GamificationState {}

class GamificationLoaded extends GamificationState {
  final int coins;
  final int streak;
  final UserLevel level;
  final List<Achievement> achievements;

  const GamificationLoaded({
    required this.coins,
    required this.streak,
    required this.level,
    required this.achievements,
  });

  @override
  List<Object?> get props => [coins, streak, level, achievements];

  GamificationLoaded copyWith({
    int? coins,
    int? streak,
    UserLevel? level,
    List<Achievement>? achievements,
  }) {
    return GamificationLoaded(
      coins: coins ?? this.coins,
      streak: streak ?? this.streak,
      level: level ?? this.level,
      achievements: achievements ?? this.achievements,
    );
  }
}

class GamificationError extends GamificationState {
  final String message;

  const GamificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class AchievementUnlocked extends GamificationState {
  final Achievement achievement;

  const AchievementUnlocked(this.achievement);

  @override
  List<Object?> get props => [achievement];
}

// ═══════════════════════════════════════════════════════════════════════════
// CUBIT
// ═══════════════════════════════════════════════════════════════════════════

class GamificationCubit extends Cubit<GamificationState> {
  final GamificationService _gamificationService;
  final String userId;

  GamificationCubit({
    required GamificationService gamificationService,
    required this.userId,
  })  : _gamificationService = gamificationService,
        super(GamificationInitial());

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> loadGamificationData() async {
    try {
      emit(GamificationLoading());

      final coins = await _gamificationService.getCoinBalance(userId);
      final streak = await _gamificationService.getCurrentStreak(userId);
      final level = await _gamificationService.getUserLevel(userId);
      final achievements = await _gamificationService.getUserAchievements(userId);

      emit(GamificationLoaded(
        coins: coins,
        streak: streak,
        level: level,
        achievements: achievements,
      ));
    } catch (e) {
      emit(GamificationError('Failed to load gamification data: $e'));
    }
  }

  Future<void> checkDailyStreak() async {
    try {
      final newStreak = await _gamificationService.updateDailyStreak(userId);

      if (state is GamificationLoaded) {
        final currentState = state as GamificationLoaded;
        
        // Reload to get updated coins from streak bonus
        await loadGamificationData();

        // Show celebration if streak increased
        if (newStreak > currentState.streak) {
          // Trigger celebration animation
        }
      }
    } catch (e) {
      print('Error checking streak: $e');
    }
  }

  Future<void> rewardForAction(CoinAction action) async {
    try {
      await _gamificationService.rewardForAction(userId, action);
      await loadGamificationData();
      await _gamificationService.checkAchievements(userId);
    } catch (e) {
      print('Error rewarding action: $e');
    }
  }

  Future<bool> spendCoins(int amount, String reason) async {
    try {
      final success = await _gamificationService.spendCoins(userId, amount, reason);
      
      if (success) {
        await loadGamificationData();
      }
      
      return success;
    } catch (e) {
      print('Error spending coins: $e');
      return false;
    }
  }

  Future<void> unlockAchievement(Achievement achievement) async {
    try {
      await _gamificationService.unlockAchievement(userId, achievement);
      
      // Show achievement notification
      emit(AchievementUnlocked(achievement));
      
      // Reload data
      await Future.delayed(const Duration(seconds: 2));
      await loadGamificationData();
    } catch (e) {
      print('Error unlocking achievement: $e');
    }
  }

  String get levelName {
    if (state is GamificationLoaded) {
      final level = (state as GamificationLoaded).level;
      return _gamificationService.getLevelName(level);
    }
    return 'Newbie';
  }

  String get levelEmoji {
    if (state is GamificationLoaded) {
      final level = (state as GamificationLoaded).level;
      return _gamificationService.getLevelEmoji(level);
    }
    return '🌱';
  }

  int get coinBalance {
    if (state is GamificationLoaded) {
      return (state as GamificationLoaded).coins;
    }
    return 0;
  }

  int get currentStreak {
    if (state is GamificationLoaded) {
      return (state as GamificationLoaded).streak;
    }
    return 0;
  }
}
