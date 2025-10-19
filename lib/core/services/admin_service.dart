import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _adminUsers = ['gyS6J2CgkIV9kHOi2sK969EFsug1']; // Admin user IDs
  final List<String> _adminEmails = ['turhanhamza@gmail.com']; // Admin emails

  AdminService();

  /// Check if current user is admin
  bool isAdmin() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;
    
    // Check by UID
    if (_adminUsers.contains(currentUser.uid)) return true;
    
    // Check by email
    if (_adminEmails.contains(currentUser.email)) return true;
    
    return false;
  }

  /// Add admin by email (emergency admin setup)
  Future<bool> addAdminByEmail(String email) async {
    try {
      _adminEmails.add(email);
      print('Added admin email: $email');
      
      // Also update in Firestore for persistence
      await _firestore.collection('admin_config').doc('admin_emails').set({
        'emails': _adminEmails,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      
      return true;
    } catch (e) {
      print('Error adding admin: $e');
      return false;
    }
  }

  /// Get admin dashboard statistics
  Future<AdminStats> getAdminStats() async {
    if (!isAdmin()) {
      throw Exception('Admin access required');
    }

    try {
      // Execute all queries in parallel for better performance
      final futures = await Future.wait([
        _firestore.collection('users').get(),
        _firestore.collection('items').get(),
        _firestore.collection('conversations').get(),
        _firestore.collection('tradeOffers').get(),
        _firestore.collection('payments').get(),
        _firestore.collection('subscriptions').get(),
      ]);

      final usersSnapshot = futures[0];
      final itemsSnapshot = futures[1];
      final conversationsSnapshot = futures[2];
      final tradesSnapshot = futures[3];
      final paymentsSnapshot = futures[4];
      final subscriptionsSnapshot = futures[5];

      // Basic counts
      final totalUsers = usersSnapshot.docs.length;
      final totalItems = itemsSnapshot.docs.length;
      final totalConversations = conversationsSnapshot.docs.length;
      final totalTrades = tradesSnapshot.docs.length;
      final totalRevenue = _calculateTotalRevenue(paymentsSnapshot);

      // Active users (last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final activeUsers = usersSnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final lastSeen = data['lastSeenAt'] as String?;
        if (lastSeen == null) return false;
        return DateTime.parse(lastSeen).isAfter(thirtyDaysAgo);
      }).length;

      // Active items
      final activeItems = itemsSnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['status'] == 'active';
      }).length;

      // Active conversations
      final activeConversations = conversationsSnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final lastMessage = data['lastMessageAt'] as String?;
        if (lastMessage == null) return false;
        return DateTime.parse(lastMessage).isAfter(thirtyDaysAgo);
      }).length;

      // Active trades
      final activeTrades = tradesSnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['status'] == 'pending';
      }).length;

      // Premium subscribers
      final premiumSubscribers = subscriptionsSnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['isActive'] == true && data['planType'] != 'free';
      }).length;

      // Category distribution
      final categoryStats = await _getCategoryStats(itemsSnapshot);

      // Weekly user growth
      final weeklyGrowth = await _calculateWeeklyGrowth(usersSnapshot);

      // Revenue this month
      final monthlyRevenue = _calculateMonthlyRevenue(paymentsSnapshot);

      return AdminStats(
        totalUsers: totalUsers,
        activeUsers: activeUsers,
        totalItems: totalItems,
        activeItems: activeItems,
        totalConversations: totalConversations,
        activeConversations: activeConversations,
        totalTrades: totalTrades,
        activeTrades: activeTrades,
        totalRevenue: totalRevenue,
        monthlyRevenue: monthlyRevenue,
        premiumSubscribers: premiumSubscribers,
        categoryStats: categoryStats,
        weeklyGrowth: weeklyGrowth,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('Error getting admin stats: $e');
      return AdminStats();
    }
  }

  /// Get all users for admin management
  Future<List<AdminUser>> getAllUsers() async {
    if (!isAdmin()) {
      throw Exception('Admin access required');
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AdminUser(
          id: doc.id,
          email: data['email'] ?? '',
          displayName: data['displayName'] ?? '',
          createdAt: DateTime.parse(data['createdAt'] ?? '1970-01-01'),
          lastSeenAt: data['lastSeenAt'] != null 
              ? DateTime.parse(data['lastSeenAt'])
              : null,
          isPremium: data['subscriptionPlan'] == 'premium',
          itemsCount: data['itemsCount'] ?? 0,
          tradesCount: data['tradesCount'] ?? 0,
          rating: data['averageRating']?.toDouble() ?? 0.0,
          isBanned: data['isBanned'] ?? false,
          isVerified: data['isVerified'] ?? false,
        );
      }).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  /// Get all items for admin management
  Future<List<AdminItem>> getAllItems() async {
    if (!isAdmin()) {
      throw Exception('Admin access required');
    }

    try {
      final snapshot = await _firestore
          .collection('items')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AdminItem(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          ownerName: data['ownerName'] ?? '',
          category: data['category'] ?? '',
          price: data['price']?.toDouble() ?? 0.0,
          status: data['status'] ?? 'active',
          createdAt: DateTime.parse(data['createdAt'] ?? '1970-01-01'),
          views: data['views'] ?? 0,
          favorites: data['favorites'] ?? 0,
          isFeatured: data['isFeatured'] ?? false,
          isReported: data['isReported'] ?? false,
          reports: (data['reports'] as List?)?.cast<Map<String, dynamic>>() ?? [],
        );
      }).toList();
    } catch (e) {
      print('Error getting items: $e');
      return [];
    }
  }

  /// Ban or unban user
  Future<bool> banUnbanUser(String userId, bool isBanned) async {
    if (!isAdmin()) {
      throw Exception('Admin access required');
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'isBanned': isBanned});

      if (isBanned) {
        // Cancel active trades and disable user's items
        await _disableUserActivity(userId);
      }

      return true;
    } catch (e) {
      print('Error banning/unbanning user: $e');
      return false;
    }
  }

  /// Verify user
  Future<bool> verifyUser(String userId) async {
    if (!isAdmin()) {
      throw Exception('Admin access required');
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'isVerified': true});

      return true;
    } catch (e) {
      print('Error verifying user: $e');
      return false;
    }
  }

  /// Feature/unfeature item
  Future<bool> featureItem(String itemId, bool isFeatured) async {
    if (!isAdmin()) {
      throw Exception('Admin access required');
    }

    try {
      await _firestore
          .collection('items')
          .doc(itemId)
          .update({'isFeatured': isFeatured});

      return true;
    } catch (e) {
      print('Error featuring item: $e');
      return false;
    }
  }

  /// Remove reported content
  Future<bool> removeReportedContent(String collectionName, String docId) async {
    if (!isAdmin()) {
      throw Exception('Admin access required');
    }

    try {
      await _firestore.collection(collectionName).doc(docId).delete();
      return true;
    } catch (e) {
      print('Error removing content: $e');
      return false;
    }
  }

  /// Get reported content
  Future<List<ReportedContent>> getReportedContent() async {
    if (!isAdmin()) {
      throw Exception('Admin access required');
    }

    final reportedItems = <ReportedContent>[];
    
    // Get reported items
    try {
      final itemsSnapshot = await _firestore
          .collection('items')
          .where('isReported', isEqualTo: true)
          .get();

      for (final doc in itemsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        reportedItems.add(ReportedContent(
          type: 'item',
          id: doc.id,
          title: data['title'] ?? '',
          reason: data['reports']?.isNotEmpty == true 
              ? (data['reports'] as List).first['reason'] as String? ?? 'Unknown'
              : 'Unknown',
          reporterId: data['reports']?.isNotEmpty == true 
              ? (data['reports'] as List).first['reporterId'] as String?
              : null,
          reportedAt: data['reports']?.isNotEmpty == true 
              ? DateTime.parse((data['reports'] as List).first['reportedAt'] as String? ?? '1970-01-01')
              : DateTime.now(),
        ));
      }
    } catch (e) {
      print('Error getting reported items: $e');
    }

    return reportedItems;
  }

  /// Disable user activity when banned
  Future<void> _disableUserActivity(String userId) async {
    try {
      // Cancel user's active trades
      final tradesSnapshot = await _firestore
          .collection('trades')
          .where('initiatorId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      for (final doc in tradesSnapshot.docs) {
        await doc.reference.update({
          'status': 'cancelled',
          'cancelledAt': DateTime.now().toIso8601String(),
        });
      }

      // Hide user's items
      final itemsSnapshot = await _firestore
          .collection('items')
          .where('ownerId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .get();

      for (final doc in itemsSnapshot.docs) {
        await doc.reference.update({'status': 'hidden'});
      }
    } catch (e) {
      print('Error disabling user activity: $e');
    }
  }

  /// Calculate total revenue
  double _calculateTotalRevenue(QuerySnapshot paymentsSnapshot) {
    double total = 0.0;
    for (final doc in paymentsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = data['amount'] as double?;
      if (amount != null && data['status'] == 'success') {
        total += amount;
      }
    }
    return total;
  }

  /// Calculate monthly revenue
  double _calculateMonthlyRevenue(QuerySnapshot paymentsSnapshot) {
    double total = 0.0;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).subtract(const Duration(days: 1));

    for (final doc in paymentsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = DateTime.parse(data['createdAt'] ?? '1970-01-01');
      final amount = data['amount'] as double?;
      if (amount != null && 
          data['status'] == 'success' && 
          createdAt.isAfter(firstDayOfMonth) && 
          createdAt.isBefore(lastDayOfMonth)) {
        total += amount;
      }
    }
    return total;
  }

  /// Get category statistics
  Future<Map<String, int>> _getCategoryStats(QuerySnapshot itemsSnapshot) {
    final Map<String, int> categoryCount = {};
    
    for (final doc in itemsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final category = data['category'] as String? ?? 'other';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }
    
    return Future.value(categoryCount);
  }

  /// Calculate weekly user growth
  double _calculateWeeklyGrowth(QuerySnapshot usersSnapshot) {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final twoWeeksAgo = now.subtract(const Duration(days: 14));

    final thisWeek = usersSnapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = DateTime.parse(data['createdAt'] ?? '1970-01-01');
      return createdAt.isAfter(oneWeekAgo);
    }).length;

    final lastWeek = usersSnapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = DateTime.parse(data['createdAt'] ?? '1970-01-01');
      return createdAt.isAfter(twoWeeksAgo) && createdAt.isBefore(oneWeekAgo);
    }).length;

    return lastWeek > 0 ? (thisWeek - lastWeek) / lastWeek * 100 : 0;
  }
}

/// Admin statistics
class AdminStats {
  final int totalUsers;
  final int activeUsers;
  final int totalItems;
  final int activeItems;
  final int totalConversations;
  final int activeConversations;
  final int totalTrades;
  final int activeTrades;
  final double totalRevenue;
  final double monthlyRevenue;
  final int premiumSubscribers;
  final Map<String, int> categoryStats;
  final double weeklyGrowth;
  final DateTime lastUpdated;

  AdminStats({
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.totalItems = 0,
    this.activeItems = 0,
    this.totalConversations = 0,
    this.activeConversations = 0,
    this.totalTrades = 0,
    this.activeTrades = 0,
    this.totalRevenue = 0.0,
    this.monthlyRevenue = 0.0,
    this.premiumSubscribers = 0,
    this.categoryStats = const {},
    this.weeklyGrowth = 0.0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();
}

/// Admin user information
class AdminUser {
  final String id;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final DateTime? lastSeenAt;
  final bool isPremium;
  final int itemsCount;
  final int tradesCount;
  final double rating;
  final bool isBanned;
  final bool isVerified;

  AdminUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.lastSeenAt,
    this.isPremium = false,
    this.itemsCount = 0,
    this.tradesCount = 0,
    this.rating = 0.0,
    this.isBanned = false,
    this.isVerified = false,
  });
}

/// Admin item information
class AdminItem {
  final String id;
  final String title;
  final String description;
  final String ownerName;
  final String category;
  final double price;
  final String status;
  final DateTime createdAt;
  final int views;
  final int favorites;
  final bool isFeatured;
  final bool isReported;
  final List<Map<String, dynamic>> reports;

  AdminItem({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerName,
    required this.category,
    required this.price,
    required this.status,
    required this.createdAt,
    this.views = 0,
    this.favorites = 0,
    this.isFeatured = false,
    this.isReported = false,
    this.reports = const [],
  });
}

/// Reported content
class ReportedContent {
  final String type;
  final String id;
  final String title;
  final String reason;
  final String? reporterId;
  final DateTime reportedAt;

  ReportedContent({
    required this.type,
    required this.id,
    required this.title,
    required this.reason,
    this.reporterId,
    required this.reportedAt,
  });
}
