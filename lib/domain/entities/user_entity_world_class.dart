import 'package:equatable/equatable.dart';

/// WORLD-CLASS User Entity
/// Based on Depop, Vinted, Poshmark, OfferUp best practices
/// 
/// Features:
/// - Verification & Trust (TruYou, Blue Tick)
/// - Ratings & Reviews (Love Notes, Feedback)
/// - Seller Stats (Sales, Response Time, Shipping)
/// - Social Features (Followers, Following)
/// - Badge System (Achievements, Trust Levels)
/// - Subscription & Premium
class UserEntityWorldClass extends Equatable {
  // ========================================
  // BASIC INFO
  // ========================================
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEmailVerified;

  // ========================================
  // PROFILE INFO
  // ========================================
  final String? bio;
  final String? address;
  final String? city;
  final String? district;
  final double? latitude;
  final double? longitude;
  final String? fullAddress;
  final String? coverPhotoUrl;
  final String? website;
  final List<String>? socialMediaLinks;

  // ========================================
  // VERIFICATION & TRUST (OfferUp TruYou + Depop)
  // ========================================
  final bool isPhoneVerified;
  final bool isEmailVerifiedManual;
  final bool isIdVerified; // TruYou style ID verification
  final bool isSelfieVerified; // TruYou style selfie verification
  final bool isFacebookConnected;
  final bool isGoogleConnected;
  final DateTime? verifiedAt;
  final VerificationLevel verificationLevel;
  
  // ========================================
  // SELLER STATS (Poshmark + Depop)
  // ========================================
  final int totalSales;
  final int totalPurchases;
  final double totalEarnings;
  final int activeListings;
  final int soldListings;
  final int totalListings;
  final DateTime? firstSaleDate;
  final DateTime? lastSaleDate;
  
  // ========================================
  // RATINGS & REVIEWS (All platforms)
  // ========================================
  final double averageRating; // 0.0 - 5.0
  final int totalReviews;
  final int fiveStarReviews;
  final int fourStarReviews;
  final int threeStarReviews;
  final int twoStarReviews;
  final int oneStarReviews;
  
  // Review attributes (OfferUp style)
  final int timelyCount; // "Timely" compliment
  final int friendlyCount; // "Friendly" compliment
  final int reliableCount; // "Reliable" compliment
  final int asDescribedCount; // "As Described" compliment
  
  // ========================================
  // RESPONSE & SHIPPING (Depop + OfferUp)
  // ========================================
  final ResponseTimeCategory responseTimeCategory;
  final String? averageResponseTime; // "Within 1 hour", "Within 1 day", etc.
  final int? averageResponseMinutes; // Actual minutes for calculation
  final double replyRate; // 0-100% (OfferUp Reply Rate Badge)
  final int messagesReceived;
  final int messagesReplied;
  
  final ShippingSpeedCategory shippingSpeedCategory;
  final double? averageShippingDays;
  final int itemsShippedOnTime;
  final int totalItemsShipped;
  final bool fastShipper; // Shipped within 3 days
  
  // ========================================
  // SOCIAL FEATURES (Poshmark + Depop)
  // ========================================
  final int followersCount;
  final int followingCount;
  final List<String>? followers; // User IDs
  final List<String>? following; // User IDs
  
  // ========================================
  // BADGES & ACHIEVEMENTS (All platforms)
  // ========================================
  final bool isTopSeller; // Depop Top Seller
  final bool isTrustedSeller; // Vinted Trusted Seller
  final bool isVerifiedSeller; // Blue tick (Depop)
  final bool hasReplyRateBadge; // OfferUp Reply Rate
  final bool hasFastShipperBadge;
  final bool hasTopRatedBadge;
  final List<String> badges; // All earned badges
  final TrustScore trustScore; // Custom trust score calculation
  
  // ========================================
  // SUBSCRIPTION & PREMIUM (Poshmark + others)
  // ========================================
  final bool isPremium;
  final String? subscriptionPlan; // 'basic', 'pro', 'premium'
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final bool hasAutoRelist;
  final bool hasPromotedListings;
  final bool hasPrioritySupport;
  
  // ========================================
  // ACTIVITY & ENGAGEMENT
  // ========================================
  final DateTime? lastActiveAt;
  final int totalFavoritesReceived;
  final int totalFavoritesGiven;
  final int totalViewsReceived;
  final int totalSharesReceived;
  final int totalOffersSent;
  final int totalOffersReceived;
  
  // ========================================
  // PREFERENCES
  // ========================================
  final List<String>? interests; // Fashion, Electronics, etc.
  final List<String>? preferredCategories;
  final bool notificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool smsNotificationsEnabled;
  final String? preferredLanguage;
  final String? preferredCurrency;
  
  // ========================================
  // SAFETY & MODERATION
  // ========================================
  final bool isSuspended;
  final bool isBanned;
  final String? suspensionReason;
  final DateTime? suspendedUntil;
  final int warningsCount;
  final int reportedCount;
  final int reportsFiledCount;

  const UserEntityWorldClass({
    // Basic
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    required this.createdAt,
    this.updatedAt,
    this.isEmailVerified = false,

    // Profile
    this.bio,
    this.address,
    this.city,
    this.district,
    this.latitude,
    this.longitude,
    this.fullAddress,
    this.coverPhotoUrl,
    this.website,
    this.socialMediaLinks,

    // Verification
    this.isPhoneVerified = false,
    this.isEmailVerifiedManual = false,
    this.isIdVerified = false,
    this.isSelfieVerified = false,
    this.isFacebookConnected = false,
    this.isGoogleConnected = false,
    this.verifiedAt,
    this.verificationLevel = VerificationLevel.none,

    // Seller Stats
    this.totalSales = 0,
    this.totalPurchases = 0,
    this.totalEarnings = 0.0,
    this.activeListings = 0,
    this.soldListings = 0,
    this.totalListings = 0,
    this.firstSaleDate,
    this.lastSaleDate,

    // Ratings & Reviews
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.fiveStarReviews = 0,
    this.fourStarReviews = 0,
    this.threeStarReviews = 0,
    this.twoStarReviews = 0,
    this.oneStarReviews = 0,
    this.timelyCount = 0,
    this.friendlyCount = 0,
    this.reliableCount = 0,
    this.asDescribedCount = 0,

    // Response & Shipping
    this.responseTimeCategory = ResponseTimeCategory.notAvailable,
    this.averageResponseTime,
    this.averageResponseMinutes,
    this.replyRate = 0.0,
    this.messagesReceived = 0,
    this.messagesReplied = 0,
    this.shippingSpeedCategory = ShippingSpeedCategory.standard,
    this.averageShippingDays,
    this.itemsShippedOnTime = 0,
    this.totalItemsShipped = 0,
    this.fastShipper = false,

    // Social
    this.followersCount = 0,
    this.followingCount = 0,
    this.followers,
    this.following,

    // Badges
    this.isTopSeller = false,
    this.isTrustedSeller = false,
    this.isVerifiedSeller = false,
    this.hasReplyRateBadge = false,
    this.hasFastShipperBadge = false,
    this.hasTopRatedBadge = false,
    this.badges = const [],
    this.trustScore = TrustScore.new_,

    // Subscription
    this.isPremium = false,
    this.subscriptionPlan,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.hasAutoRelist = false,
    this.hasPromotedListings = false,
    this.hasPrioritySupport = false,

    // Activity
    this.lastActiveAt,
    this.totalFavoritesReceived = 0,
    this.totalFavoritesGiven = 0,
    this.totalViewsReceived = 0,
    this.totalSharesReceived = 0,
    this.totalOffersSent = 0,
    this.totalOffersReceived = 0,

    // Preferences
    this.interests,
    this.preferredCategories,
    this.notificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.smsNotificationsEnabled = false,
    this.preferredLanguage,
    this.preferredCurrency,

    // Safety
    this.isSuspended = false,
    this.isBanned = false,
    this.suspensionReason,
    this.suspendedUntil,
    this.warningsCount = 0,
    this.reportedCount = 0,
    this.reportsFiledCount = 0,
  });

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        phoneNumber,
        photoUrl,
        createdAt,
        updatedAt,
        // ... (all fields for equality check)
      ];

  /// Calculate trust score based on multiple factors
  TrustScore calculateTrustScore() {
    int score = 0;

    // Verification (40 points max)
    if (isPhoneVerified) score += 10;
    if (isEmailVerifiedManual) score += 10;
    if (isIdVerified) score += 15;
    if (isSelfieVerified) score += 5;

    // Sales history (20 points max)
    if (totalSales >= 50) score += 20;
    else if (totalSales >= 20) score += 15;
    else if (totalSales >= 5) score += 10;
    else if (totalSales >= 1) score += 5;

    // Ratings (20 points max)
    if (averageRating >= 4.8) score += 20;
    else if (averageRating >= 4.5) score += 15;
    else if (averageRating >= 4.0) score += 10;
    else if (averageRating >= 3.5) score += 5;

    // Response & Shipping (10 points max)
    if (replyRate >= 90) score += 5;
    if (fastShipper) score += 5;

    // Badges (10 points max)
    if (isTopSeller) score += 5;
    if (isTrustedSeller) score += 5;

    // Convert score to TrustScore enum
    if (score >= 85) return TrustScore.excellent;
    if (score >= 70) return TrustScore.verygood;
    if (score >= 50) return TrustScore.good;
    if (score >= 30) return TrustScore.fair;
    return TrustScore.new_;
  }

  /// Get response time display string
  String get responseTimeDisplay {
    if (averageResponseTime != null) return averageResponseTime!;
    
    if (averageResponseMinutes == null) return 'Not available';
    
    final mins = averageResponseMinutes!;
    if (mins < 60) return 'Within $mins minutes';
    if (mins < 1440) return 'Within ${(mins / 60).round()} hours';
    return 'Within ${(mins / 1440).round()} days';
  }

  UserEntityWorldClass copyWith({
    // Add all fields as optional parameters
    String? displayName,
    String? bio,
    double? averageRating,
    // ... etc
  }) {
    return UserEntityWorldClass(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      // ... etc
      createdAt: createdAt,
    );
  }
}

// ========================================
// ENUMS
// ========================================

enum VerificationLevel {
  none,       // No verification
  basic,      // Email + Phone
  standard,   // Basic + ID
  verified,   // Standard + Selfie
  premium,    // Verified + Facebook/Google
}

enum ResponseTimeCategory {
  instant,      // < 1 hour
  veryfast,     // 1-6 hours
  fast,         // 6-24 hours
  moderate,     // 1-2 days
  slow,         // 2+ days
  notAvailable, // No data
}

enum ShippingSpeedCategory {
  sameDay,      // Same day
  nextDay,      // 1 day
  fast,         // 2-3 days
  standard,     // 4-7 days
  slow,         // 7+ days
}

enum TrustScore {
  new_,         // New user, no history
  fair,         // Some history, mixed reviews
  good,         // Good history, positive reviews
  verygood,     // Excellent history, great reviews
  excellent,    // Perfect history, top seller
}
