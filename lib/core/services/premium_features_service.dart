import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/entities/item_entity.dart';

/// Premium Features Service
/// 
/// World-class premium features management inspired by:
/// - Airbnb (premium listing placement)
/// - LinkedIn Premium (profile boost)
/// - Tinder Gold (priority visibility)
/// - OfferUp (featured ads)
class PremiumFeaturesService {
  static PremiumFeaturesService? _instance;
  static PremiumFeaturesService get instance => _instance ??= PremiumFeaturesService._();

  PremiumFeaturesService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if user can create new listing
  Future<CanCreateListingResult> canCreateListing({
    required String userId,
    required SubscriptionPlan plan,
  }) async {
    try {
      // Get user's active listings count
      final activeListings = await _firestore
          .collection('items')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['active', 'pending'])
          .count()
          .get();

      final currentCount = activeListings.count ?? 0;
      final maxAllowed = plan.features.maxActiveListings;

      if (currentCount >= maxAllowed) {
        return CanCreateListingResult(
          canCreate: false,
          currentCount: currentCount,
          maxAllowed: maxAllowed,
          reason: 'Maximum active listing limit reached',
          suggestedAction: plan == SubscriptionPlan.free
              ? 'Upgrade to Basic plan for 10 listings or Premium for 50 listings'
              : plan == SubscriptionPlan.basic
                  ? 'Upgrade to Premium for 50 listings'
                  : 'Delete some listings to create new ones',
        );
      }

      return CanCreateListingResult(
        canCreate: true,
        currentCount: currentCount,
        maxAllowed: maxAllowed,
      );
    } catch (e) {
      return CanCreateListingResult(
        canCreate: false,
        currentCount: 0,
        maxAllowed: plan.features.maxActiveListings,
        reason: 'Error checking listing limit: $e',
      );
    }
  }

  /// Check if user needs to pay listing fee
  Future<ListingFeeResult> checkListingFee({
    required String userId,
    required SubscriptionPlan plan,
    required bool isPremiumListing,
  }) async {
    try {
      // Get current month's listing count
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      final monthlyListings = await _firestore
          .collection('items')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
          .count()
          .get();

      final currentMonthCount = monthlyListings.count ?? 0;
      final freeAllowance = plan.features.freeListingsPerMonth;

      // Premium listing check
      if (isPremiumListing) {
        final premiumAllowance = plan.features.premiumListingsPerMonth;
        
        // Get premium listings this month
        final premiumCount = await _firestore
            .collection('premium_listings')
            .where('userId', isEqualTo: userId)
            .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
            .count()
            .get();

        final currentPremiumCount = premiumCount.count ?? 0;

        if (currentPremiumCount >= premiumAllowance) {
          return ListingFeeResult(
            needsPayment: true,
            amount: ListingFeeConfig.premiumListingFee,
            freeAllowanceUsed: currentPremiumCount,
            freeAllowanceTotal: premiumAllowance,
            isPremiumListing: true,
            message: 'Premium listing quota exceeded. Pay ₺${ListingFeeConfig.premiumListingFee} to continue.',
          );
        }

        return ListingFeeResult(
          needsPayment: false,
          amount: 0,
          freeAllowanceUsed: currentPremiumCount,
          freeAllowanceTotal: premiumAllowance,
          isPremiumListing: true,
          message: 'Premium listing quota available (${currentPremiumCount}/${premiumAllowance} used)',
        );
      }

      // Standard listing check
      if (currentMonthCount >= freeAllowance) {
        return ListingFeeResult(
          needsPayment: true,
          amount: ListingFeeConfig.standardListingFee,
          freeAllowanceUsed: currentMonthCount,
          freeAllowanceTotal: freeAllowance,
          isPremiumListing: false,
          message: 'Free listing quota exceeded. Pay ₺${ListingFeeConfig.standardListingFee} to continue.',
        );
      }

      return ListingFeeResult(
        needsPayment: false,
        amount: 0,
        freeAllowanceUsed: currentMonthCount,
        freeAllowanceTotal: freeAllowance,
        isPremiumListing: false,
        message: 'Free listing quota available (${currentMonthCount}/${freeAllowance} used)',
      );
    } catch (e) {
      return ListingFeeResult(
        needsPayment: false,
        amount: 0,
        freeAllowanceUsed: 0,
        freeAllowanceTotal: plan.features.freeListingsPerMonth,
        isPremiumListing: isPremiumListing,
        message: 'Error checking listing fee: $e',
      );
    }
  }

  /// Create premium listing
  Future<String?> createPremiumListing({
    required String userId,
    required String itemId,
    required PremiumListingType type,
    String? paymentId,
  }) async {
    try {
      final now = DateTime.now();
      final duration = type.durationDays;
      final endDate = now.add(Duration(days: duration));

      final premiumListingData = {
        'userId': userId,
        'itemId': itemId,
        'type': type.name,
        'startDate': Timestamp.fromDate(now),
        'endDate': Timestamp.fromDate(endDate),
        'isActive': true,
        'paymentId': paymentId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection('premium_listings')
          .add(premiumListingData);

      // Update item with premium flag
      await _firestore.collection('items').doc(itemId).update({
        'isPremium': true,
        'premiumListingId': docRef.id,
        'premiumExpiryDate': Timestamp.fromDate(endDate),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('❌ Create premium listing error: $e');
      return null;
    }
  }

  /// Check if user should see ads
  bool shouldShowAds(SubscriptionPlan plan) {
    return !plan.features.adFree;
  }

  /// Calculate trade commission
  double calculateTradeCommission({
    required double tradeValue,
    required SubscriptionPlan plan,
  }) {
    return ListingFeeConfig.calculateCommission(tradeValue, plan);
  }

  /// Get premium badge for UI
  String getPremiumBadge(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return '';
      case SubscriptionPlan.basic:
        return '⭐';
      case SubscriptionPlan.premium:
        return '💎';
    }
  }

  /// Get premium color for UI
  String getPremiumColor(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return '#757575'; // Grey
      case SubscriptionPlan.basic:
        return '#2196F3'; // Blue
      case SubscriptionPlan.premium:
        return '#FF6B35'; // Premium Orange
    }
  }

  /// Check if item is premium listing
  Future<bool> isItemPremium(String itemId) async {
    try {
      final doc = await _firestore.collection('items').doc(itemId).get();
      final data = doc.data();
      
      if (data == null) return false;
      
      final isPremium = data['isPremium'] as bool? ?? false;
      if (!isPremium) return false;

      // Check if premium is still active
      final expiryDate = data['premiumExpiryDate'] as Timestamp?;
      if (expiryDate == null) return false;

      return DateTime.now().isBefore(expiryDate.toDate());
    } catch (e) {
      return false;
    }
  }

  /// Get premium listing boost score for search ranking
  /// Inspired by Airbnb's Plus and Tinder's Boost
  double getPremiumBoostScore(bool isPremium, PremiumListingType? type) {
    if (!isPremium || type == null) return 1.0;

    switch (type) {
      case PremiumListingType.featured7Days:
        return 3.0; // 3x visibility
      case PremiumListingType.featured14Days:
        return 3.5; // 3.5x visibility
      case PremiumListingType.featured30Days:
        return 4.0; // 4x visibility
      case PremiumListingType.topOfSearch:
        return 5.0; // 5x visibility (always on top)
    }
  }

  /// Analytics tracking for premium features
  Future<void> trackPremiumFeatureUsage({
    required String userId,
    required String featureName,
    required SubscriptionPlan plan,
  }) async {
    try {
      await _firestore.collection('premium_analytics').add({
        'userId': userId,
        'featureName': featureName,
        'plan': plan.name,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Track premium feature error: $e');
    }
  }

  /// Get user's subscription benefits summary
  Future<SubscriptionBenefitsSummary> getUserBenefits({
    required String userId,
    required SubscriptionPlan plan,
  }) async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      // Get monthly stats
      final [activeListingsQuery, monthlyListingsQuery, premiumListingsQuery] = await Future.wait([
        _firestore
            .collection('items')
            .where('userId', isEqualTo: userId)
            .where('status', whereIn: ['active', 'pending'])
            .count()
            .get(),
        _firestore
            .collection('items')
            .where('userId', isEqualTo: userId)
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
            .count()
            .get(),
        _firestore
            .collection('premium_listings')
            .where('userId', isEqualTo: userId)
            .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
            .count()
            .get(),
      ]);

      final activeListings = activeListingsQuery.count ?? 0;
      final monthlyListings = monthlyListingsQuery.count ?? 0;
      final premiumListings = premiumListingsQuery.count ?? 0;

      final features = plan.features;

      return SubscriptionBenefitsSummary(
        plan: plan,
        activeListings: activeListings,
        maxActiveListings: features.maxActiveListings,
        monthlyListingsUsed: monthlyListings,
        monthlyListingsAllowance: features.freeListingsPerMonth,
        premiumListingsUsed: premiumListings,
        premiumListingsAllowance: features.premiumListingsPerMonth,
        isAdFree: features.adFree,
        commissionRate: features.tradeCommissionRate,
        hasPrioritySupport: features.prioritySupport,
        hasAdvancedSearch: features.advancedSearch,
        hasAnalyticsAccess: features.analyticsAccess,
      );
    } catch (e) {
      // Return default
      final features = plan.features;
      return SubscriptionBenefitsSummary(
        plan: plan,
        activeListings: 0,
        maxActiveListings: features.maxActiveListings,
        monthlyListingsUsed: 0,
        monthlyListingsAllowance: features.freeListingsPerMonth,
        premiumListingsUsed: 0,
        premiumListingsAllowance: features.premiumListingsPerMonth,
        isAdFree: features.adFree,
        commissionRate: features.tradeCommissionRate,
        hasPrioritySupport: features.prioritySupport,
        hasAdvancedSearch: features.advancedSearch,
        hasAnalyticsAccess: features.analyticsAccess,
      );
    }
  }
}

/// Can create listing result
class CanCreateListingResult {
  final bool canCreate;
  final int currentCount;
  final int maxAllowed;
  final String? reason;
  final String? suggestedAction;

  CanCreateListingResult({
    required this.canCreate,
    required this.currentCount,
    required this.maxAllowed,
    this.reason,
    this.suggestedAction,
  });
}

/// Listing fee result
class ListingFeeResult {
  final bool needsPayment;
  final double amount;
  final int freeAllowanceUsed;
  final int freeAllowanceTotal;
  final bool isPremiumListing;
  final String message;

  ListingFeeResult({
    required this.needsPayment,
    required this.amount,
    required this.freeAllowanceUsed,
    required this.freeAllowanceTotal,
    required this.isPremiumListing,
    required this.message,
  });

  int get remainingFreeListings => (freeAllowanceTotal - freeAllowanceUsed).clamp(0, freeAllowanceTotal);
}

/// Subscription benefits summary
class SubscriptionBenefitsSummary {
  final SubscriptionPlan plan;
  final int activeListings;
  final int maxActiveListings;
  final int monthlyListingsUsed;
  final int monthlyListingsAllowance;
  final int premiumListingsUsed;
  final int premiumListingsAllowance;
  final bool isAdFree;
  final double commissionRate;
  final bool hasPrioritySupport;
  final bool hasAdvancedSearch;
  final bool hasAnalyticsAccess;

  SubscriptionBenefitsSummary({
    required this.plan,
    required this.activeListings,
    required this.maxActiveListings,
    required this.monthlyListingsUsed,
    required this.monthlyListingsAllowance,
    required this.premiumListingsUsed,
    required this.premiumListingsAllowance,
    required this.isAdFree,
    required this.commissionRate,
    required this.hasPrioritySupport,
    required this.hasAdvancedSearch,
    required this.hasAnalyticsAccess,
  });

  int get remainingActiveSlots => maxActiveListings - activeListings;
  int get remainingMonthlyListings => (monthlyListingsAllowance - monthlyListingsUsed).clamp(0, 999);
  int get remainingPremiumListings => (premiumListingsAllowance - premiumListingsUsed).clamp(0, 999);
  
  double get activeListingsPercentage => 
      maxActiveListings > 0 ? (activeListings / maxActiveListings * 100).clamp(0, 100) : 0;
  
  double get monthlyListingsPercentage =>
      monthlyListingsAllowance > 0 && monthlyListingsAllowance < 999
          ? (monthlyListingsUsed / monthlyListingsAllowance * 100).clamp(0, 100)
          : 0;
}
