import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/subscription_entity.dart';

/// Subscription Management Service
/// 
/// Handles subscription lifecycle inspired by world-class services:
/// - Netflix (auto-renewal, grace period)
/// - Spotify Premium (seamless upgrades)
/// - YouTube Premium (family sharing)
class SubscriptionManagementService {
  static SubscriptionManagementService? _instance;
  static SubscriptionManagementService get instance =>
      _instance ??= SubscriptionManagementService._();

  SubscriptionManagementService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get user's current subscription
  Future<SubscriptionEntity?> getUserSubscription(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      return _subscriptionFromFirestore(doc);
    } catch (e) {
      print('❌ Get subscription error: $e');
      return null;
    }
  }

  /// Check if subscription is active and valid
  Future<bool> isSubscriptionActive(String userId) async {
    final subscription = await getUserSubscription(userId);
    return subscription != null && subscription.isActive;
  }

  /// Get subscription plan for user (returns free if no active subscription)
  Future<SubscriptionPlan> getUserPlan(String userId) async {
    final subscription = await getUserSubscription(userId);
    
    if (subscription == null || !subscription.isActive) {
      return SubscriptionPlan.free;
    }

    return subscription.plan;
  }

  /// Create new subscription
  Future<String?> createSubscription({
    required String userId,
    required SubscriptionPlan plan,
    required String storeProductId,
    required String storeTransactionId,
    String? paymentId,
    bool isYearly = false,
  }) async {
    try {
      // Cancel any existing active subscriptions first
      await _cancelExistingSubscriptions(userId);

      final now = DateTime.now();
      final duration = isYearly ? 365 : 30; // days
      final expiryDate = now.add(Duration(days: duration));

      final subscriptionData = {
        'userId': userId,
        'plan': plan.name,
        'status': 'active',
        'startDate': Timestamp.fromDate(now),
        'expiryDate': Timestamp.fromDate(expiryDate),
        'autoRenew': true,
        'storeProductId': storeProductId,
        'storeTransactionId': storeTransactionId,
        'paymentId': paymentId,
        'createdAt': FieldValue.serverTimestamp(),
        'lastRenewedAt': Timestamp.fromDate(now),
        'cancelledAt': null,
      };

      final docRef = await _firestore
          .collection('subscriptions')
          .add(subscriptionData);

      // Update user document
      await _updateUserSubscription(userId, plan, docRef.id);

      print('✅ Subscription created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Create subscription error: $e');
      return null;
    }
  }

  /// Renew subscription (called by webhook or scheduled function)
  Future<bool> renewSubscription(String subscriptionId) async {
    try {
      final doc = await _firestore
          .collection('subscriptions')
          .doc(subscriptionId)
          .get();

      if (!doc.exists) return false;

      final subscription = _subscriptionFromFirestore(doc);
      if (!subscription.autoRenew) return false;

      final now = DateTime.now();
      final newExpiryDate = subscription.expiryDate.add(const Duration(days: 30));

      await _firestore.collection('subscriptions').doc(subscriptionId).update({
        'expiryDate': Timestamp.fromDate(newExpiryDate),
        'lastRenewedAt': Timestamp.fromDate(now),
        'status': 'active',
      });

      print('✅ Subscription renewed: $subscriptionId');
      return true;
    } catch (e) {
      print('❌ Renew subscription error: $e');
      return false;
    }
  }

  /// Cancel subscription
  Future<bool> cancelSubscription(String userId) async {
    try {
      final subscription = await getUserSubscription(userId);
      if (subscription == null) return false;

      final now = DateTime.now();

      await _firestore.collection('subscriptions').doc(subscription.id).update({
        'status': 'cancelled',
        'cancelledAt': Timestamp.fromDate(now),
        'autoRenew': false,
      });

      // Update user document
      await _updateUserSubscription(userId, SubscriptionPlan.free, null);

      print('✅ Subscription cancelled: ${subscription.id}');
      return true;
    } catch (e) {
      print('❌ Cancel subscription error: $e');
      return false;
    }
  }

  /// Upgrade subscription
  Future<String?> upgradeSubscription({
    required String userId,
    required SubscriptionPlan newPlan,
    required String storeProductId,
    required String storeTransactionId,
    String? paymentId,
  }) async {
    try {
      final currentSubscription = await getUserSubscription(userId);
      
      // Cancel current subscription
      if (currentSubscription != null) {
        await _firestore
            .collection('subscriptions')
            .doc(currentSubscription.id)
            .update({
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
          'autoRenew': false,
        });
      }

      // Create new subscription with remaining days credited
      final remainingDays = currentSubscription != null
          ? currentSubscription.daysUntilExpiry
          : 0;

      final now = DateTime.now();
      final baseExpiry = now.add(const Duration(days: 30));
      final creditedExpiry = baseExpiry.add(Duration(days: remainingDays));

      final subscriptionData = {
        'userId': userId,
        'plan': newPlan.name,
        'status': 'active',
        'startDate': Timestamp.fromDate(now),
        'expiryDate': Timestamp.fromDate(creditedExpiry),
        'autoRenew': true,
        'storeProductId': storeProductId,
        'storeTransactionId': storeTransactionId,
        'paymentId': paymentId,
        'createdAt': FieldValue.serverTimestamp(),
        'lastRenewedAt': Timestamp.fromDate(now),
        'cancelledAt': null,
        'upgradedFrom': currentSubscription?.plan.name,
      };

      final docRef = await _firestore
          .collection('subscriptions')
          .add(subscriptionData);

      await _updateUserSubscription(userId, newPlan, docRef.id);

      print('✅ Subscription upgraded to $newPlan: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Upgrade subscription error: $e');
      return null;
    }
  }

  /// Check and handle expired subscriptions
  Future<void> checkExpiredSubscriptions() async {
    try {
      final now = DateTime.now();
      
      final expiredSnapshots = await _firestore
          .collection('subscriptions')
          .where('status', isEqualTo: 'active')
          .where('expiryDate', isLessThan: Timestamp.fromDate(now))
          .get();

      for (var doc in expiredSnapshots.docs) {
        final subscription = _subscriptionFromFirestore(doc);
        
        if (subscription.autoRenew) {
          // Try to renew
          await renewSubscription(subscription.id);
        } else {
          // Mark as expired
          await _firestore.collection('subscriptions').doc(subscription.id).update({
            'status': 'expired',
          });

          // Downgrade user to free
          await _updateUserSubscription(
            subscription.userId,
            SubscriptionPlan.free,
            null,
          );
        }
      }

      print('✅ Checked expired subscriptions: ${expiredSnapshots.docs.length}');
    } catch (e) {
      print('❌ Check expired subscriptions error: $e');
    }
  }

  /// Get subscription history for user
  Future<List<SubscriptionEntity>> getSubscriptionHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => _subscriptionFromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Get subscription history error: $e');
      return [];
    }
  }

  /// Cancel existing active subscriptions for user
  Future<void> _cancelExistingSubscriptions(String userId) async {
    final activeSubscriptions = await _firestore
        .collection('subscriptions')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .get();

    final now = DateTime.now();

    for (var doc in activeSubscriptions.docs) {
      await doc.reference.update({
        'status': 'cancelled',
        'cancelledAt': Timestamp.fromDate(now),
        'autoRenew': false,
      });
    }
  }

  /// Update user document with subscription info
  Future<void> _updateUserSubscription(
    String userId,
    SubscriptionPlan plan,
    String? subscriptionId,
  ) async {
    await _firestore.collection('users').doc(userId).update({
      'subscriptionPlan': plan.name,
      'subscriptionStatus': plan == SubscriptionPlan.free ? 'free' : 'active',
      'subscriptionId': subscriptionId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Convert Firestore document to SubscriptionEntity
  SubscriptionEntity _subscriptionFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    
    return SubscriptionEntity(
      id: doc.id,
      userId: data['userId'] as String,
      plan: _planFromString(data['plan'] as String),
      status: _statusFromString(data['status'] as String),
      startDate: (data['startDate'] as Timestamp).toDate(),
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      cancelledAt: data['cancelledAt'] != null
          ? (data['cancelledAt'] as Timestamp).toDate()
          : null,
      autoRenew: data['autoRenew'] as bool? ?? true,
      paymentId: data['paymentId'] as String?,
      storeProductId: data['storeProductId'] as String?,
      storeTransactionId: data['storeTransactionId'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastRenewedAt: data['lastRenewedAt'] != null
          ? (data['lastRenewedAt'] as Timestamp).toDate()
          : null,
    );
  }

  SubscriptionPlan _planFromString(String plan) {
    switch (plan) {
      case 'basic':
        return SubscriptionPlan.basic;
      case 'premium':
        return SubscriptionPlan.premium;
      default:
        return SubscriptionPlan.free;
    }
  }

  SubscriptionStatus _statusFromString(String status) {
    switch (status) {
      case 'active':
        return SubscriptionStatus.active;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      case 'paused':
        return SubscriptionStatus.paused;
      default:
        return SubscriptionStatus.expired;
    }
  }
}
