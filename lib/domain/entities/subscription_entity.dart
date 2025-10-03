import 'package:equatable/equatable.dart';

/// Subscription Entity - Kullanıcı abonelik bilgileri
class SubscriptionEntity extends Equatable {
  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime expiryDate;
  final DateTime? cancelledAt;
  final bool autoRenew;
  final String? paymentId;
  final String? storeProductId;
  final String? storeTransactionId;
  final DateTime createdAt;
  final DateTime? lastRenewedAt;

  const SubscriptionEntity({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.expiryDate,
    this.cancelledAt,
    this.autoRenew = true,
    this.paymentId,
    this.storeProductId,
    this.storeTransactionId,
    required this.createdAt,
    this.lastRenewedAt,
  });

  /// Check if subscription is currently active
  bool get isActive {
    return status == SubscriptionStatus.active &&
        DateTime.now().isBefore(expiryDate);
  }

  /// Check if subscription has premium features
  bool get isPremium => plan != SubscriptionPlan.free;

  /// Days until expiry
  int get daysUntilExpiry {
    return expiryDate.difference(DateTime.now()).inDays;
  }

  /// Check if expiring soon (within 3 days)
  bool get isExpiringSoon {
    return isActive && daysUntilExpiry <= 3;
  }

  SubscriptionEntity copyWith({
    String? id,
    String? userId,
    SubscriptionPlan? plan,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? expiryDate,
    DateTime? cancelledAt,
    bool? autoRenew,
    String? paymentId,
    String? storeProductId,
    String? storeTransactionId,
    DateTime? createdAt,
    DateTime? lastRenewedAt,
  }) {
    return SubscriptionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      autoRenew: autoRenew ?? this.autoRenew,
      paymentId: paymentId ?? this.paymentId,
      storeProductId: storeProductId ?? this.storeProductId,
      storeTransactionId: storeTransactionId ?? this.storeTransactionId,
      createdAt: createdAt ?? this.createdAt,
      lastRenewedAt: lastRenewedAt ?? this.lastRenewedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        plan,
        status,
        startDate,
        expiryDate,
        cancelledAt,
        autoRenew,
        paymentId,
        storeProductId,
        storeTransactionId,
        createdAt,
        lastRenewedAt,
      ];
}

/// Subscription Plans
enum SubscriptionPlan {
  free, // Ücretsiz plan
  basic, // Temel plan
  premium, // Premium plan
}

/// Subscription Status
enum SubscriptionStatus {
  active, // Aktif
  expired, // Süresi dolmuş
  cancelled, // İptal edilmiş
  paused, // Duraklatılmış
}

/// Subscription Features - Her plan için özellikler
class SubscriptionFeatures {
  final SubscriptionPlan plan;
  final String displayName;
  final String description;
  final double monthlyPriceTRY;
  final double yearlyPriceTRY;
  final String? storeProductIdMonthly;
  final String? storeProductIdYearly;

  // Feature limits
  final int maxActiveListings; // Maksimum aktif ilan sayısı
  final int freeListingsPerMonth; // Ayda ücretsiz ilan hakkı
  final bool premiumListingAvailable; // Premium ilan yapabilir mi
  final int premiumListingsPerMonth; // Ayda premium ilan hakkı
  final bool adFree; // Reklamsız
  final double tradeCommissionRate; // Trade komisyon oranı (%)
  final bool prioritySupport; // Öncelikli destek
  final bool advancedSearch; // Gelişmiş arama
  final bool analyticsAccess; // İstatistik erişimi

  const SubscriptionFeatures({
    required this.plan,
    required this.displayName,
    required this.description,
    required this.monthlyPriceTRY,
    required this.yearlyPriceTRY,
    this.storeProductIdMonthly,
    this.storeProductIdYearly,
    required this.maxActiveListings,
    required this.freeListingsPerMonth,
    required this.premiumListingAvailable,
    required this.premiumListingsPerMonth,
    required this.adFree,
    required this.tradeCommissionRate,
    required this.prioritySupport,
    required this.advancedSearch,
    required this.analyticsAccess,
  });

  /// Get yearly price with discount
  double get yearlyPriceMonthlyEquivalent => yearlyPriceTRY / 12;

  /// Calculate yearly savings
  double get yearlySavings => (monthlyPriceTRY * 12) - yearlyPriceTRY;

  /// Calculate yearly discount percentage
  double get yearlyDiscountPercentage =>
      (yearlySavings / (monthlyPriceTRY * 12)) * 100;
}

/// Predefined subscription plans
class SubscriptionPlans {
  static const free = SubscriptionFeatures(
    plan: SubscriptionPlan.free,
    displayName: '🆓 Ücretsiz',
    description: 'Temel özellikler',
    monthlyPriceTRY: 0,
    yearlyPriceTRY: 0,
    maxActiveListings: 3, // Maksimum 3 aktif ilan
    freeListingsPerMonth: 1, // Ayda 1 ücretsiz ilan
    premiumListingAvailable: false, // Premium ilan yok
    premiumListingsPerMonth: 0,
    adFree: false, // Reklamlı
    tradeCommissionRate: 5.0, // %5 komisyon
    prioritySupport: false,
    advancedSearch: false,
    analyticsAccess: false,
  );

  static const basic = SubscriptionFeatures(
    plan: SubscriptionPlan.basic,
    displayName: '⭐ Temel',
    description: 'Daha fazla ilan ve özellik',
    monthlyPriceTRY: 49.99,
    yearlyPriceTRY: 499.99, // ~%17 indirim
    storeProductIdMonthly: 'barter_qween_basic_monthly',
    storeProductIdYearly: 'barter_qween_basic_yearly',
    maxActiveListings: 10, // Maksimum 10 aktif ilan
    freeListingsPerMonth: 5, // Ayda 5 ücretsiz ilan
    premiumListingAvailable: true,
    premiumListingsPerMonth: 2, // Ayda 2 premium ilan
    adFree: true, // Reklamsız
    tradeCommissionRate: 3.0, // %3 komisyon
    prioritySupport: false,
    advancedSearch: true,
    analyticsAccess: true,
  );

  static const premium = SubscriptionFeatures(
    plan: SubscriptionPlan.premium,
    displayName: '💎 Premium',
    description: 'Tüm özellikler sınırsız',
    monthlyPriceTRY: 99.99,
    yearlyPriceTRY: 999.99, // ~%17 indirim
    storeProductIdMonthly: 'barter_qween_premium_monthly',
    storeProductIdYearly: 'barter_qween_premium_yearly',
    maxActiveListings: 50, // Maksimum 50 aktif ilan
    freeListingsPerMonth: 999, // Sınırsız ücretsiz ilan
    premiumListingAvailable: true,
    premiumListingsPerMonth: 10, // Ayda 10 premium ilan
    adFree: true, // Reklamsız
    tradeCommissionRate: 0.0, // %0 komisyon
    prioritySupport: true,
    advancedSearch: true,
    analyticsAccess: true,
  );

  /// Get features for a plan
  static SubscriptionFeatures getFeatures(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return free;
      case SubscriptionPlan.basic:
        return basic;
      case SubscriptionPlan.premium:
        return premium;
    }
  }

  /// Get all available plans
  static List<SubscriptionFeatures> get allPlans => [free, basic, premium];

  /// Get paid plans only
  static List<SubscriptionFeatures> get paidPlans => [basic, premium];
}

/// Extension for SubscriptionPlan
extension SubscriptionPlanExtension on SubscriptionPlan {
  SubscriptionFeatures get features => SubscriptionPlans.getFeatures(this);

  String get displayName => features.displayName;

  bool get isFree => this == SubscriptionPlan.free;
  bool get isBasic => this == SubscriptionPlan.basic;
  bool get isPremium => this == SubscriptionPlan.premium;
}

/// Extension for SubscriptionStatus
extension SubscriptionStatusExtension on SubscriptionStatus {
  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Aktif';
      case SubscriptionStatus.expired:
        return 'Süresi Doldu';
      case SubscriptionStatus.cancelled:
        return 'İptal Edildi';
      case SubscriptionStatus.paused:
        return 'Duraklatıldı';
    }
  }

  bool get isActive => this == SubscriptionStatus.active;
}

/// Listing Fee Configuration
class ListingFeeConfig {
  // İlan verme ücretleri (TRY)
  static const double standardListingFee = 9.99;
  static const double premiumListingFee = 29.99;
  static const int premiumListingDuration = 7; // 7 gün öne çıkar

  // Komisyon oranları (%)
  static const double defaultCommissionRate = 5.0;
  static const double basicPlanCommissionRate = 3.0;
  static const double premiumPlanCommissionRate = 0.0;

  /// Calculate commission for a trade
  static double calculateCommission(
    double tradeValue,
    SubscriptionPlan plan,
  ) {
    final rate = plan.features.tradeCommissionRate;
    return (tradeValue * rate) / 100;
  }

  /// Check if user needs to pay listing fee
  static bool needsToPayListingFee(
    SubscriptionPlan plan,
    int currentMonthListings,
  ) {
    final freeListings = plan.features.freeListingsPerMonth;
    return currentMonthListings >= freeListings;
  }

  /// Get listing fee for user
  static double getListingFee(
    SubscriptionPlan plan,
    int currentMonthListings,
    bool isPremiumListing,
  ) {
    // Premium ilan ise
    if (isPremiumListing) {
      final premiumListingsUsed = currentMonthListings; // Simplified
      final premiumAllowance = plan.features.premiumListingsPerMonth;
      
      if (premiumListingsUsed >= premiumAllowance) {
        return premiumListingFee;
      }
      return 0.0;
    }

    // Normal ilan
    if (needsToPayListingFee(plan, currentMonthListings)) {
      return standardListingFee;
    }
    return 0.0;
  }
}

/// Premium listing feature
class PremiumListingEntity extends Equatable {
  final String id;
  final String itemId;
  final String userId;
  final PremiumListingType type;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? paymentId;

  const PremiumListingEntity({
    required this.id,
    required this.itemId,
    required this.userId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.paymentId,
  });

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isValid => isActive && !isExpired;

  @override
  List<Object?> get props => [
        id,
        itemId,
        userId,
        type,
        startDate,
        endDate,
        isActive,
        paymentId,
      ];
}

enum PremiumListingType {
  featured7Days,
  featured14Days,
  featured30Days,
  topOfSearch,
}

extension PremiumListingTypeExtension on PremiumListingType {
  String get displayName {
    switch (this) {
      case PremiumListingType.featured7Days:
        return '7 Gün Öne Çıkan';
      case PremiumListingType.featured14Days:
        return '14 Gün Öne Çıkan';
      case PremiumListingType.featured30Days:
        return '30 Gün Öne Çıkan';
      case PremiumListingType.topOfSearch:
        return 'Arama Sonuçlarında Üstte';
    }
  }

  String get price {
    switch (this) {
      case PremiumListingType.featured7Days:
        return '₺29';
      case PremiumListingType.featured14Days:
        return '₺49';
      case PremiumListingType.featured30Days:
        return '₺79';
      case PremiumListingType.topOfSearch:
        return '₺19';
    }
  }

  String get productId {
    switch (this) {
      case PremiumListingType.featured7Days:
        return 'com.barterqween.featured.7days';
      case PremiumListingType.featured14Days:
        return 'com.barterqween.featured.14days';
      case PremiumListingType.featured30Days:
        return 'com.barterqween.featured.30days';
      case PremiumListingType.topOfSearch:
        return 'com.barterqween.topsearch';
    }
  }

  int get durationDays {
    switch (this) {
      case PremiumListingType.featured7Days:
        return 7;
      case PremiumListingType.featured14Days:
        return 14;
      case PremiumListingType.featured30Days:
        return 30;
      case PremiumListingType.topOfSearch:
        return 7;
    }
  }
}
