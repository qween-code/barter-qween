// 🎮 GAMIFICATION SERVICE
// Coins, Achievements, Streaks, Levels

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GamificationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  GamificationService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  // ═══════════════════════════════════════════════════════════════════════════
  // COINS SYSTEM
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get user's current coin balance
  Future<int> getCoinBalance(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?['coins'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Add coins to user account
  Future<void> addCoins(String userId, int amount, String reason) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        final currentCoins = snapshot.data()?['coins'] ?? 0;
        final newTotal = currentCoins + amount;

        transaction.update(userRef, {
          'coins': newTotal,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Log transaction
        transaction.set(
          _firestore.collection('users').doc(userId).collection('coinHistory').doc(),
          {
            'amount': amount,
            'reason': reason,
            'balance': newTotal,
            'createdAt': FieldValue.serverTimestamp(),
          },
        );
      });

      // Check for coin milestones
      await _checkCoinMilestones(userId);
    } catch (e) {
      print('Error adding coins: $e');
    }
  }

  /// Spend coins
  Future<bool> spendCoins(String userId, int amount, String reason) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        final currentCoins = snapshot.data()?['coins'] ?? 0;

        if (currentCoins < amount) {
          return false; // Insufficient coins
        }

        final newTotal = currentCoins - amount;

        transaction.update(userRef, {
          'coins': newTotal,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Log transaction
        transaction.set(
          _firestore.collection('users').doc(userId).collection('coinHistory').doc(),
          {
            'amount': -amount,
            'reason': reason,
            'balance': newTotal,
            'createdAt': FieldValue.serverTimestamp(),
          },
        );

        return true;
      });
    } catch (e) {
      print('Error spending coins: $e');
      return false;
    }
  }

  /// Coin earning events
  Future<void> rewardForAction(String userId, CoinAction action) async {
    final amount = _getCoinAmount(action);
    final reason = _getActionDescription(action);
    await addCoins(userId, amount, reason);
  }

  int _getCoinAmount(CoinAction action) {
    switch (action) {
      case CoinAction.listItem:
        return 10;
      case CoinAction.completeTrade:
        return 50;
      case CoinAction.dailyLogin:
        return 5;
      case CoinAction.referral:
        return 100;
      case CoinAction.firstTrade:
        return 25;
      case CoinAction.profileComplete:
        return 20;
      case CoinAction.verifyPhone:
        return 15;
      case CoinAction.verifyEmail:
        return 10;
      case CoinAction.addPhoto:
        return 5;
      case CoinAction.writeReview:
        return 15;
    }
  }

  String _getActionDescription(CoinAction action) {
    switch (action) {
      case CoinAction.listItem:
        return 'Listed an item';
      case CoinAction.completeTrade:
        return 'Completed a trade';
      case CoinAction.dailyLogin:
        return 'Daily login bonus';
      case CoinAction.referral:
        return 'Referred a friend';
      case CoinAction.firstTrade:
        return 'First trade bonus';
      case CoinAction.profileComplete:
        return 'Profile completion bonus';
      case CoinAction.verifyPhone:
        return 'Phone verification bonus';
      case CoinAction.verifyEmail:
        return 'Email verification bonus';
      case CoinAction.addPhoto:
        return 'Added photo to item';
      case CoinAction.writeReview:
        return 'Wrote a review';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STREAKS SYSTEM
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check and update daily streak
  Future<int> updateDailyStreak(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final snapshot = await userRef.get();
      final data = snapshot.data() ?? {};

      final lastLoginTimestamp = data['lastLoginDate'] as Timestamp?;
      final currentStreak = data['currentStreak'] ?? 0;
      final longestStreak = data['longestStreak'] ?? 0;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (lastLoginTimestamp == null) {
        // First login
        await userRef.update({
          'lastLoginDate': Timestamp.fromDate(today),
          'currentStreak': 1,
          'longestStreak': 1,
        });
        await rewardForAction(userId, CoinAction.dailyLogin);
        return 1;
      }

      final lastLogin = lastLoginTimestamp.toDate();
      final lastLoginDay = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
      final daysDifference = today.difference(lastLoginDay).inDays;

      if (daysDifference == 0) {
        // Already logged in today
        return currentStreak;
      } else if (daysDifference == 1) {
        // Consecutive day
        final newStreak = currentStreak + 1;
        final newLongest = newStreak > longestStreak ? newStreak : longestStreak;

        await userRef.update({
          'lastLoginDate': Timestamp.fromDate(today),
          'currentStreak': newStreak,
          'longestStreak': newLongest,
        });

        // Reward daily login
        await rewardForAction(userId, CoinAction.dailyLogin);

        // Bonus for streak milestones
        if (newStreak % 7 == 0) {
          await addCoins(userId, 50, '7-day streak bonus!');
        }
        if (newStreak % 30 == 0) {
          await addCoins(userId, 200, '30-day streak bonus!');
        }

        // Check streak achievements
        await _checkStreakAchievements(userId, newStreak);

        return newStreak;
      } else {
        // Streak broken
        await userRef.update({
          'lastLoginDate': Timestamp.fromDate(today),
          'currentStreak': 1,
        });
        await rewardForAction(userId, CoinAction.dailyLogin);
        return 1;
      }
    } catch (e) {
      print('Error updating streak: $e');
      return 0;
    }
  }

  /// Get current streak
  Future<int> getCurrentStreak(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?['currentStreak'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LEVELS SYSTEM
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get user level based on coins
  Future<UserLevel> getUserLevel(String userId) async {
    final coins = await getCoinBalance(userId);
    return _calculateLevel(coins);
  }

  UserLevel _calculateLevel(int coins) {
    if (coins < 100) return UserLevel.newbie;
    if (coins < 500) return UserLevel.trader;
    if (coins < 2000) return UserLevel.proTrader;
    return UserLevel.masterTrader;
  }

  String getLevelName(UserLevel level) {
    switch (level) {
      case UserLevel.newbie:
        return 'Newbie';
      case UserLevel.trader:
        return 'Trader';
      case UserLevel.proTrader:
        return 'Pro Trader';
      case UserLevel.masterTrader:
        return 'Master Trader';
    }
  }

  String getLevelEmoji(UserLevel level) {
    switch (level) {
      case UserLevel.newbie:
        return '🌱';
      case UserLevel.trader:
        return '⭐';
      case UserLevel.proTrader:
        return '🔥';
      case UserLevel.masterTrader:
        return '👑';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACHIEVEMENTS SYSTEM
  // ═══════════════════════════════════════════════════════════════════════════

  /// Unlock achievement
  Future<void> unlockAchievement(String userId, Achievement achievement) async {
    try {
      final achievementRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievement.id);

      final snapshot = await achievementRef.get();
      if (snapshot.exists) {
        return; // Already unlocked
      }

      await achievementRef.set({
        'id': achievement.id,
        'name': achievement.name,
        'description': achievement.description,
        'icon': achievement.icon,
        'coinReward': achievement.coinReward,
        'unlockedAt': FieldValue.serverTimestamp(),
      });

      // Reward coins
      if (achievement.coinReward > 0) {
        await addCoins(userId, achievement.coinReward, 'Achievement: ${achievement.name}');
      }
    } catch (e) {
      print('Error unlocking achievement: $e');
    }
  }

  /// Get all achievements
  Future<List<Achievement>> getUserAchievements(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Achievement(
          id: data['id'],
          name: data['name'],
          description: data['description'],
          icon: data['icon'],
          coinReward: data['coinReward'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Check and unlock achievements based on stats
  Future<void> checkAchievements(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final data = userDoc.data() ?? {};

      final totalTrades = data['totalTrades'] ?? 0;
      final totalListed = data['totalListed'] ?? 0;
      final rating = data['rating'] ?? 0.0;

      // Trade milestones
      if (totalTrades >= 1) {
        await unlockAchievement(userId, Achievement.firstTrade());
      }
      if (totalTrades >= 10) {
        await unlockAchievement(userId, Achievement.tenTrades());
      }
      if (totalTrades >= 50) {
        await unlockAchievement(userId, Achievement.fiftyTrades());
      }
      if (totalTrades >= 100) {
        await unlockAchievement(userId, Achievement.hundredTrades());
      }

      // Listing milestones
      if (totalListed >= 5) {
        await unlockAchievement(userId, Achievement.fiveListings());
      }
      if (totalListed >= 20) {
        await unlockAchievement(userId, Achievement.twentyListings());
      }

      // Rating achievements
      if (rating >= 4.5 && totalTrades >= 10) {
        await unlockAchievement(userId, Achievement.highRating());
      }
      if (rating == 5.0 && totalTrades >= 20) {
        await unlockAchievement(userId, Achievement.perfectRating());
      }
    } catch (e) {
      print('Error checking achievements: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _checkCoinMilestones(String userId) async {
    final coins = await getCoinBalance(userId);

    if (coins >= 1000) {
      await unlockAchievement(userId, Achievement.thousandCoins());
    }
    if (coins >= 5000) {
      await unlockAchievement(userId, Achievement.fiveThousandCoins());
    }
  }

  Future<void> _checkStreakAchievements(String userId, int streak) async {
    if (streak >= 7) {
      await unlockAchievement(userId, Achievement.weekStreak());
    }
    if (streak >= 30) {
      await unlockAchievement(userId, Achievement.monthStreak());
    }
    if (streak >= 100) {
      await unlockAchievement(userId, Achievement.hundredDayStreak());
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ENUMS & MODELS
// ═══════════════════════════════════════════════════════════════════════════

enum CoinAction {
  listItem,
  completeTrade,
  dailyLogin,
  referral,
  firstTrade,
  profileComplete,
  verifyPhone,
  verifyEmail,
  addPhoto,
  writeReview,
}

enum UserLevel {
  newbie, // 0-100 coins
  trader, // 101-500
  proTrader, // 501-2000
  masterTrader, // 2001+
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int coinReward;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.coinReward,
  });

  // Predefined achievements
  static Achievement firstTrade() => Achievement(
        id: 'first_trade',
        name: 'First Trade',
        description: 'Complete your first successful trade',
        icon: '🎯',
        coinReward: 25,
      );

  static Achievement tenTrades() => Achievement(
        id: 'ten_trades',
        name: '10 Trades',
        description: 'Complete 10 successful trades',
        icon: '⭐',
        coinReward: 50,
      );

  static Achievement fiftyTrades() => Achievement(
        id: 'fifty_trades',
        name: '50 Trades',
        description: 'Complete 50 successful trades',
        icon: '🔥',
        coinReward: 100,
      );

  static Achievement hundredTrades() => Achievement(
        id: 'hundred_trades',
        name: '100 Trades',
        description: 'Complete 100 successful trades',
        icon: '👑',
        coinReward: 250,
      );

  static Achievement fiveListings() => Achievement(
        id: 'five_listings',
        name: '5 Listings',
        description: 'List 5 items for trade',
        icon: '📦',
        coinReward: 20,
      );

  static Achievement twentyListings() => Achievement(
        id: 'twenty_listings',
        name: '20 Listings',
        description: 'List 20 items for trade',
        icon: '📚',
        coinReward: 50,
      );

  static Achievement weekStreak() => Achievement(
        id: 'week_streak',
        name: 'Week Streak',
        description: 'Log in for 7 consecutive days',
        icon: '🔥',
        coinReward: 50,
      );

  static Achievement monthStreak() => Achievement(
        id: 'month_streak',
        name: 'Month Streak',
        description: 'Log in for 30 consecutive days',
        icon: '💎',
        coinReward: 200,
      );

  static Achievement hundredDayStreak() => Achievement(
        id: 'hundred_day_streak',
        name: '100 Day Streak',
        description: 'Log in for 100 consecutive days',
        icon: '🏆',
        coinReward: 1000,
      );

  static Achievement highRating() => Achievement(
        id: 'high_rating',
        name: 'Highly Rated',
        description: 'Maintain 4.5+ star rating with 10+ trades',
        icon: '⭐',
        coinReward: 75,
      );

  static Achievement perfectRating() => Achievement(
        id: 'perfect_rating',
        name: 'Perfect Rating',
        description: 'Maintain 5.0 star rating with 20+ trades',
        icon: '🌟',
        coinReward: 150,
      );

  static Achievement thousandCoins() => Achievement(
        id: 'thousand_coins',
        name: '1,000 Coins',
        description: 'Accumulate 1,000 Barter Coins',
        icon: '🪙',
        coinReward: 100,
      );

  static Achievement fiveThousandCoins() => Achievement(
        id: 'five_thousand_coins',
        name: '5,000 Coins',
        description: 'Accumulate 5,000 Barter Coins',
        icon: '💰',
        coinReward: 500,
      );
}
