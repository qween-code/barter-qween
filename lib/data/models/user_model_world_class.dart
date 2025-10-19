import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity_world_class.dart';

/// WORLD-CLASS User Model
/// Complete Firestore mapping for UserEntityWorldClass
class UserModelWorldClass {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEmailVerified;

  // Profile
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

  // Verification
  final bool isPhoneVerified;
  final bool isEmailVerifiedManual;
  final bool isIdVerified;
  final bool isSelfieVerified;
  final bool isFacebookConnected;
  final bool isGoogleConnected;
  final DateTime? verifiedAt;
  final String verificationLevel;

  // Seller Stats
  final int totalSales;
  final int totalPurchases;
  final double totalEarnings;
  final int activeListings;
  final int soldListings;
  final int totalListings;
  final DateTime? firstSaleDate;
  final DateTime? lastSaleDate;

  // Ratings & Reviews
  final double averageRating;
  final int totalReviews;
  final int fiveStarReviews;
  final int fourStarReviews;
  final int threeStarReviews;
  final int twoStarReviews;
  final int oneStarReviews;
  final int timelyCount;
  final int friendlyCount;
  final int reliableCount;
  final int asDescribedCount;

  // Response & Shipping
  final String responseTimeCategory;
  final String? averageResponseTime;
  final int? averageResponseMinutes;
  final double replyRate;
  final int messagesReceived;
  final int messagesReplied;
  final String shippingSpeedCategory;
  final double? averageShippingDays;
  final int itemsShippedOnTime;
  final int totalItemsShipped;
  final bool fastShipper;

  // Social
  final int followersCount;
  final int followingCount;
  final List<String>? followers;
  final List<String>? following;

  // Badges
  final bool isTopSeller;
  final bool isTrustedSeller;
  final bool isVerifiedSeller;
  final bool hasReplyRateBadge;
  final bool hasFastShipperBadge;
  final bool hasTopRatedBadge;
  final List<String> badges;
  final String trustScore;

  // Subscription
  final bool isPremium;
  final String? subscriptionPlan;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final bool hasAutoRelist;
  final bool hasPromotedListings;
  final bool hasPrioritySupport;

  // Activity
  final DateTime? lastActiveAt;
  final int totalFavoritesReceived;
  final int totalFavoritesGiven;
  final int totalViewsReceived;
  final int totalSharesReceived;
  final int totalOffersSent;
  final int totalOffersReceived;

  // Preferences
  final List<String>? interests;
  final List<String>? preferredCategories;
  final bool notificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool smsNotificationsEnabled;
  final String? preferredLanguage;
  final String? preferredCurrency;

  // Safety
  final bool isSuspended;
  final bool isBanned;
  final String? suspensionReason;
  final DateTime? suspendedUntil;
  final int warningsCount;
  final int reportedCount;
  final int reportsFiledCount;

  UserModelWorldClass({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    required this.createdAt,
    this.updatedAt,
    this.isEmailVerified = false,
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
    this.isPhoneVerified = false,
    this.isEmailVerifiedManual = false,
    this.isIdVerified = false,
    this.isSelfieVerified = false,
    this.isFacebookConnected = false,
    this.isGoogleConnected = false,
    this.verifiedAt,
    this.verificationLevel = 'none',
    this.totalSales = 0,
    this.totalPurchases = 0,
    this.totalEarnings = 0.0,
    this.activeListings = 0,
    this.soldListings = 0,
    this.totalListings = 0,
    this.firstSaleDate,
    this.lastSaleDate,
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
    this.responseTimeCategory = 'notAvailable',
    this.averageResponseTime,
    this.averageResponseMinutes,
    this.replyRate = 0.0,
    this.messagesReceived = 0,
    this.messagesReplied = 0,
    this.shippingSpeedCategory = 'standard',
    this.averageShippingDays,
    this.itemsShippedOnTime = 0,
    this.totalItemsShipped = 0,
    this.fastShipper = false,
    this.followersCount = 0,
    this.followingCount = 0,
    this.followers,
    this.following,
    this.isTopSeller = false,
    this.isTrustedSeller = false,
    this.isVerifiedSeller = false,
    this.hasReplyRateBadge = false,
    this.hasFastShipperBadge = false,
    this.hasTopRatedBadge = false,
    this.badges = const [],
    this.trustScore = 'new',
    this.isPremium = false,
    this.subscriptionPlan,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.hasAutoRelist = false,
    this.hasPromotedListings = false,
    this.hasPrioritySupport = false,
    this.lastActiveAt,
    this.totalFavoritesReceived = 0,
    this.totalFavoritesGiven = 0,
    this.totalViewsReceived = 0,
    this.totalSharesReceived = 0,
    this.totalOffersSent = 0,
    this.totalOffersReceived = 0,
    this.interests,
    this.preferredCategories,
    this.notificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.smsNotificationsEnabled = false,
    this.preferredLanguage,
    this.preferredCurrency,
    this.isSuspended = false,
    this.isBanned = false,
    this.suspensionReason,
    this.suspendedUntil,
    this.warningsCount = 0,
    this.reportedCount = 0,
    this.reportsFiledCount = 0,
  });

  // ========================================
  // FIRESTORE MAPPING
  // ========================================

  /// From Firestore DocumentSnapshot
  factory UserModelWorldClass.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModelWorldClass(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isEmailVerified: data['isEmailVerified'] ?? false,

      // Profile
      bio: data['bio'],
      address: data['address'],
      city: data['city'],
      district: data['district'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      fullAddress: data['fullAddress'],
      coverPhotoUrl: data['coverPhotoUrl'],
      website: data['website'],
      socialMediaLinks: data['socialMediaLinks'] != null
          ? List<String>.from(data['socialMediaLinks'])
          : null,

      // Verification
      isPhoneVerified: data['isPhoneVerified'] ?? false,
      isEmailVerifiedManual: data['isEmailVerifiedManual'] ?? false,
      isIdVerified: data['isIdVerified'] ?? false,
      isSelfieVerified: data['isSelfieVerified'] ?? false,
      isFacebookConnected: data['isFacebookConnected'] ?? false,
      isGoogleConnected: data['isGoogleConnected'] ?? false,
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
      verificationLevel: data['verificationLevel'] ?? 'none',

      // Seller Stats
      totalSales: data['totalSales'] ?? 0,
      totalPurchases: data['totalPurchases'] ?? 0,
      totalEarnings: data['totalEarnings']?.toDouble() ?? 0.0,
      activeListings: data['activeListings'] ?? 0,
      soldListings: data['soldListings'] ?? 0,
      totalListings: data['totalListings'] ?? 0,
      firstSaleDate: (data['firstSaleDate'] as Timestamp?)?.toDate(),
      lastSaleDate: (data['lastSaleDate'] as Timestamp?)?.toDate(),

      // Ratings & Reviews
      averageRating: data['averageRating']?.toDouble() ?? 0.0,
      totalReviews: data['totalReviews'] ?? 0,
      fiveStarReviews: data['fiveStarReviews'] ?? 0,
      fourStarReviews: data['fourStarReviews'] ?? 0,
      threeStarReviews: data['threeStarReviews'] ?? 0,
      twoStarReviews: data['twoStarReviews'] ?? 0,
      oneStarReviews: data['oneStarReviews'] ?? 0,
      timelyCount: data['timelyCount'] ?? 0,
      friendlyCount: data['friendlyCount'] ?? 0,
      reliableCount: data['reliableCount'] ?? 0,
      asDescribedCount: data['asDescribedCount'] ?? 0,

      // Response & Shipping
      responseTimeCategory: data['responseTimeCategory'] ?? 'notAvailable',
      averageResponseTime: data['averageResponseTime'],
      averageResponseMinutes: data['averageResponseMinutes'],
      replyRate: data['replyRate']?.toDouble() ?? 0.0,
      messagesReceived: data['messagesReceived'] ?? 0,
      messagesReplied: data['messagesReplied'] ?? 0,
      shippingSpeedCategory: data['shippingSpeedCategory'] ?? 'standard',
      averageShippingDays: data['averageShippingDays']?.toDouble(),
      itemsShippedOnTime: data['itemsShippedOnTime'] ?? 0,
      totalItemsShipped: data['totalItemsShipped'] ?? 0,
      fastShipper: data['fastShipper'] ?? false,

      // Social
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      followers: data['followers'] != null
          ? List<String>.from(data['followers'])
          : null,
      following: data['following'] != null
          ? List<String>.from(data['following'])
          : null,

      // Badges
      isTopSeller: data['isTopSeller'] ?? false,
      isTrustedSeller: data['isTrustedSeller'] ?? false,
      isVerifiedSeller: data['isVerifiedSeller'] ?? false,
      hasReplyRateBadge: data['hasReplyRateBadge'] ?? false,
      hasFastShipperBadge: data['hasFastShipperBadge'] ?? false,
      hasTopRatedBadge: data['hasTopRatedBadge'] ?? false,
      badges: data['badges'] != null ? List<String>.from(data['badges']) : [],
      trustScore: data['trustScore'] ?? 'new',

      // Subscription
      isPremium: data['isPremium'] ?? false,
      subscriptionPlan: data['subscriptionPlan'],
      subscriptionStartDate: (data['subscriptionStartDate'] as Timestamp?)
          ?.toDate(),
      subscriptionEndDate: (data['subscriptionEndDate'] as Timestamp?)
          ?.toDate(),
      hasAutoRelist: data['hasAutoRelist'] ?? false,
      hasPromotedListings: data['hasPromotedListings'] ?? false,
      hasPrioritySupport: data['hasPrioritySupport'] ?? false,

      // Activity
      lastActiveAt: (data['lastActiveAt'] as Timestamp?)?.toDate(),
      totalFavoritesReceived: data['totalFavoritesReceived'] ?? 0,
      totalFavoritesGiven: data['totalFavoritesGiven'] ?? 0,
      totalViewsReceived: data['totalViewsReceived'] ?? 0,
      totalSharesReceived: data['totalSharesReceived'] ?? 0,
      totalOffersSent: data['totalOffersSent'] ?? 0,
      totalOffersReceived: data['totalOffersReceived'] ?? 0,

      // Preferences
      interests: data['interests'] != null
          ? List<String>.from(data['interests'])
          : null,
      preferredCategories: data['preferredCategories'] != null
          ? List<String>.from(data['preferredCategories'])
          : null,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      emailNotificationsEnabled: data['emailNotificationsEnabled'] ?? true,
      smsNotificationsEnabled: data['smsNotificationsEnabled'] ?? false,
      preferredLanguage: data['preferredLanguage'],
      preferredCurrency: data['preferredCurrency'],

      // Safety
      isSuspended: data['isSuspended'] ?? false,
      isBanned: data['isBanned'] ?? false,
      suspensionReason: data['suspensionReason'],
      suspendedUntil: (data['suspendedUntil'] as Timestamp?)?.toDate(),
      warningsCount: data['warningsCount'] ?? 0,
      reportedCount: data['reportedCount'] ?? 0,
      reportsFiledCount: data['reportsFiledCount'] ?? 0,
    );
  }

  /// To Firestore Map
  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isEmailVerified': isEmailVerified,

      // Profile
      'bio': bio,
      'address': address,
      'city': city,
      'district': district,
      'latitude': latitude,
      'longitude': longitude,
      'fullAddress': fullAddress,
      'coverPhotoUrl': coverPhotoUrl,
      'website': website,
      'socialMediaLinks': socialMediaLinks,

      // Verification
      'isPhoneVerified': isPhoneVerified,
      'isEmailVerifiedManual': isEmailVerifiedManual,
      'isIdVerified': isIdVerified,
      'isSelfieVerified': isSelfieVerified,
      'isFacebookConnected': isFacebookConnected,
      'isGoogleConnected': isGoogleConnected,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'verificationLevel': verificationLevel,

      // Seller Stats
      'totalSales': totalSales,
      'totalPurchases': totalPurchases,
      'totalEarnings': totalEarnings,
      'activeListings': activeListings,
      'soldListings': soldListings,
      'totalListings': totalListings,
      'firstSaleDate': firstSaleDate != null
          ? Timestamp.fromDate(firstSaleDate!)
          : null,
      'lastSaleDate': lastSaleDate != null
          ? Timestamp.fromDate(lastSaleDate!)
          : null,

      // Ratings & Reviews
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'fiveStarReviews': fiveStarReviews,
      'fourStarReviews': fourStarReviews,
      'threeStarReviews': threeStarReviews,
      'twoStarReviews': twoStarReviews,
      'oneStarReviews': oneStarReviews,
      'timelyCount': timelyCount,
      'friendlyCount': friendlyCount,
      'reliableCount': reliableCount,
      'asDescribedCount': asDescribedCount,

      // Response & Shipping
      'responseTimeCategory': responseTimeCategory,
      'averageResponseTime': averageResponseTime,
      'averageResponseMinutes': averageResponseMinutes,
      'replyRate': replyRate,
      'messagesReceived': messagesReceived,
      'messagesReplied': messagesReplied,
      'shippingSpeedCategory': shippingSpeedCategory,
      'averageShippingDays': averageShippingDays,
      'itemsShippedOnTime': itemsShippedOnTime,
      'totalItemsShipped': totalItemsShipped,
      'fastShipper': fastShipper,

      // Social
      'followersCount': followersCount,
      'followingCount': followingCount,
      'followers': followers,
      'following': following,

      // Badges
      'isTopSeller': isTopSeller,
      'isTrustedSeller': isTrustedSeller,
      'isVerifiedSeller': isVerifiedSeller,
      'hasReplyRateBadge': hasReplyRateBadge,
      'hasFastShipperBadge': hasFastShipperBadge,
      'hasTopRatedBadge': hasTopRatedBadge,
      'badges': badges,
      'trustScore': trustScore,

      // Subscription
      'isPremium': isPremium,
      'subscriptionPlan': subscriptionPlan,
      'subscriptionStartDate': subscriptionStartDate != null
          ? Timestamp.fromDate(subscriptionStartDate!)
          : null,
      'subscriptionEndDate': subscriptionEndDate != null
          ? Timestamp.fromDate(subscriptionEndDate!)
          : null,
      'hasAutoRelist': hasAutoRelist,
      'hasPromotedListings': hasPromotedListings,
      'hasPrioritySupport': hasPrioritySupport,

      // Activity
      'lastActiveAt': lastActiveAt != null
          ? Timestamp.fromDate(lastActiveAt!)
          : null,
      'totalFavoritesReceived': totalFavoritesReceived,
      'totalFavoritesGiven': totalFavoritesGiven,
      'totalViewsReceived': totalViewsReceived,
      'totalSharesReceived': totalSharesReceived,
      'totalOffersSent': totalOffersSent,
      'totalOffersReceived': totalOffersReceived,

      // Preferences
      'interests': interests,
      'preferredCategories': preferredCategories,
      'notificationsEnabled': notificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'smsNotificationsEnabled': smsNotificationsEnabled,
      'preferredLanguage': preferredLanguage,
      'preferredCurrency': preferredCurrency,

      // Safety
      'isSuspended': isSuspended,
      'isBanned': isBanned,
      'suspensionReason': suspensionReason,
      'suspendedUntil': suspendedUntil != null
          ? Timestamp.fromDate(suspendedUntil!)
          : null,
      'warningsCount': warningsCount,
      'reportedCount': reportedCount,
      'reportsFiledCount': reportsFiledCount,
    };

    // Remove null values
    map.removeWhere((key, value) => value == null);

    return map;
  }

  /// To Entity
  UserEntityWorldClass toEntity() {
    return UserEntityWorldClass(
      uid: uid,
      email: email,
      displayName: displayName,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isEmailVerified: isEmailVerified,
      bio: bio,
      address: address,
      city: city,
      district: district,
      latitude: latitude,
      longitude: longitude,
      fullAddress: fullAddress,
      coverPhotoUrl: coverPhotoUrl,
      website: website,
      socialMediaLinks: socialMediaLinks,
      isPhoneVerified: isPhoneVerified,
      isEmailVerifiedManual: isEmailVerifiedManual,
      isIdVerified: isIdVerified,
      isSelfieVerified: isSelfieVerified,
      isFacebookConnected: isFacebookConnected,
      isGoogleConnected: isGoogleConnected,
      verifiedAt: verifiedAt,
      verificationLevel: _parseVerificationLevel(verificationLevel),
      totalSales: totalSales,
      totalPurchases: totalPurchases,
      totalEarnings: totalEarnings,
      activeListings: activeListings,
      soldListings: soldListings,
      totalListings: totalListings,
      firstSaleDate: firstSaleDate,
      lastSaleDate: lastSaleDate,
      averageRating: averageRating,
      totalReviews: totalReviews,
      fiveStarReviews: fiveStarReviews,
      fourStarReviews: fourStarReviews,
      threeStarReviews: threeStarReviews,
      twoStarReviews: twoStarReviews,
      oneStarReviews: oneStarReviews,
      timelyCount: timelyCount,
      friendlyCount: friendlyCount,
      reliableCount: reliableCount,
      asDescribedCount: asDescribedCount,
      responseTimeCategory: _parseResponseTimeCategory(responseTimeCategory),
      averageResponseTime: averageResponseTime,
      averageResponseMinutes: averageResponseMinutes,
      replyRate: replyRate,
      messagesReceived: messagesReceived,
      messagesReplied: messagesReplied,
      shippingSpeedCategory: _parseShippingSpeedCategory(shippingSpeedCategory),
      averageShippingDays: averageShippingDays,
      itemsShippedOnTime: itemsShippedOnTime,
      totalItemsShipped: totalItemsShipped,
      fastShipper: fastShipper,
      followersCount: followersCount,
      followingCount: followingCount,
      followers: followers,
      following: following,
      isTopSeller: isTopSeller,
      isTrustedSeller: isTrustedSeller,
      isVerifiedSeller: isVerifiedSeller,
      hasReplyRateBadge: hasReplyRateBadge,
      hasFastShipperBadge: hasFastShipperBadge,
      hasTopRatedBadge: hasTopRatedBadge,
      badges: badges,
      trustScore: _parseTrustScore(trustScore),
      isPremium: isPremium,
      subscriptionPlan: subscriptionPlan,
      subscriptionStartDate: subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate,
      hasAutoRelist: hasAutoRelist,
      hasPromotedListings: hasPromotedListings,
      hasPrioritySupport: hasPrioritySupport,
      lastActiveAt: lastActiveAt,
      totalFavoritesReceived: totalFavoritesReceived,
      totalFavoritesGiven: totalFavoritesGiven,
      totalViewsReceived: totalViewsReceived,
      totalSharesReceived: totalSharesReceived,
      totalOffersSent: totalOffersSent,
      totalOffersReceived: totalOffersReceived,
      interests: interests,
      preferredCategories: preferredCategories,
      notificationsEnabled: notificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled,
      smsNotificationsEnabled: smsNotificationsEnabled,
      preferredLanguage: preferredLanguage,
      preferredCurrency: preferredCurrency,
      isSuspended: isSuspended,
      isBanned: isBanned,
      suspensionReason: suspensionReason,
      suspendedUntil: suspendedUntil,
      warningsCount: warningsCount,
      reportedCount: reportedCount,
      reportsFiledCount: reportsFiledCount,
    );
  }

  /// From Entity
  factory UserModelWorldClass.fromEntity(UserEntityWorldClass entity) {
    return UserModelWorldClass(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      phoneNumber: entity.phoneNumber,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isEmailVerified: entity.isEmailVerified,
      bio: entity.bio,
      address: entity.address,
      city: entity.city,
      district: entity.district,
      latitude: entity.latitude,
      longitude: entity.longitude,
      fullAddress: entity.fullAddress,
      coverPhotoUrl: entity.coverPhotoUrl,
      website: entity.website,
      socialMediaLinks: entity.socialMediaLinks,
      isPhoneVerified: entity.isPhoneVerified,
      isEmailVerifiedManual: entity.isEmailVerifiedManual,
      isIdVerified: entity.isIdVerified,
      isSelfieVerified: entity.isSelfieVerified,
      isFacebookConnected: entity.isFacebookConnected,
      isGoogleConnected: entity.isGoogleConnected,
      verifiedAt: entity.verifiedAt,
      verificationLevel: entity.verificationLevel.name,
      totalSales: entity.totalSales,
      totalPurchases: entity.totalPurchases,
      totalEarnings: entity.totalEarnings,
      activeListings: entity.activeListings,
      soldListings: entity.soldListings,
      totalListings: entity.totalListings,
      firstSaleDate: entity.firstSaleDate,
      lastSaleDate: entity.lastSaleDate,
      averageRating: entity.averageRating,
      totalReviews: entity.totalReviews,
      fiveStarReviews: entity.fiveStarReviews,
      fourStarReviews: entity.fourStarReviews,
      threeStarReviews: entity.threeStarReviews,
      twoStarReviews: entity.twoStarReviews,
      oneStarReviews: entity.oneStarReviews,
      timelyCount: entity.timelyCount,
      friendlyCount: entity.friendlyCount,
      reliableCount: entity.reliableCount,
      asDescribedCount: entity.asDescribedCount,
      responseTimeCategory: entity.responseTimeCategory.name,
      averageResponseTime: entity.averageResponseTime,
      averageResponseMinutes: entity.averageResponseMinutes,
      replyRate: entity.replyRate,
      messagesReceived: entity.messagesReceived,
      messagesReplied: entity.messagesReplied,
      shippingSpeedCategory: entity.shippingSpeedCategory.name,
      averageShippingDays: entity.averageShippingDays,
      itemsShippedOnTime: entity.itemsShippedOnTime,
      totalItemsShipped: entity.totalItemsShipped,
      fastShipper: entity.fastShipper,
      followersCount: entity.followersCount,
      followingCount: entity.followingCount,
      followers: entity.followers,
      following: entity.following,
      isTopSeller: entity.isTopSeller,
      isTrustedSeller: entity.isTrustedSeller,
      isVerifiedSeller: entity.isVerifiedSeller,
      hasReplyRateBadge: entity.hasReplyRateBadge,
      hasFastShipperBadge: entity.hasFastShipperBadge,
      hasTopRatedBadge: entity.hasTopRatedBadge,
      badges: entity.badges,
      trustScore: entity.trustScore.name,
      isPremium: entity.isPremium,
      subscriptionPlan: entity.subscriptionPlan,
      subscriptionStartDate: entity.subscriptionStartDate,
      subscriptionEndDate: entity.subscriptionEndDate,
      hasAutoRelist: entity.hasAutoRelist,
      hasPromotedListings: entity.hasPromotedListings,
      hasPrioritySupport: entity.hasPrioritySupport,
      lastActiveAt: entity.lastActiveAt,
      totalFavoritesReceived: entity.totalFavoritesReceived,
      totalFavoritesGiven: entity.totalFavoritesGiven,
      totalViewsReceived: entity.totalViewsReceived,
      totalSharesReceived: entity.totalSharesReceived,
      totalOffersSent: entity.totalOffersSent,
      totalOffersReceived: entity.totalOffersReceived,
      interests: entity.interests,
      preferredCategories: entity.preferredCategories,
      notificationsEnabled: entity.notificationsEnabled,
      emailNotificationsEnabled: entity.emailNotificationsEnabled,
      smsNotificationsEnabled: entity.smsNotificationsEnabled,
      preferredLanguage: entity.preferredLanguage,
      preferredCurrency: entity.preferredCurrency,
      isSuspended: entity.isSuspended,
      isBanned: entity.isBanned,
      suspensionReason: entity.suspensionReason,
      suspendedUntil: entity.suspendedUntil,
      warningsCount: entity.warningsCount,
      reportedCount: entity.reportedCount,
      reportsFiledCount: entity.reportsFiledCount,
    );
  }

  // ========================================
  // HELPER PARSERS
  // ========================================

  static VerificationLevel _parseVerificationLevel(String level) {
    switch (level) {
      case 'basic':
        return VerificationLevel.basic;
      case 'standard':
        return VerificationLevel.standard;
      case 'verified':
        return VerificationLevel.verified;
      case 'premium':
        return VerificationLevel.premium;
      default:
        return VerificationLevel.none;
    }
  }

  static ResponseTimeCategory _parseResponseTimeCategory(String category) {
    switch (category) {
      case 'instant':
        return ResponseTimeCategory.instant;
      case 'veryfast':
        return ResponseTimeCategory.veryfast;
      case 'fast':
        return ResponseTimeCategory.fast;
      case 'moderate':
        return ResponseTimeCategory.moderate;
      case 'slow':
        return ResponseTimeCategory.slow;
      default:
        return ResponseTimeCategory.notAvailable;
    }
  }

  static ShippingSpeedCategory _parseShippingSpeedCategory(String category) {
    switch (category) {
      case 'sameDay':
        return ShippingSpeedCategory.sameDay;
      case 'nextDay':
        return ShippingSpeedCategory.nextDay;
      case 'fast':
        return ShippingSpeedCategory.fast;
      case 'slow':
        return ShippingSpeedCategory.slow;
      default:
        return ShippingSpeedCategory.standard;
    }
  }

  static TrustScore _parseTrustScore(String score) {
    switch (score) {
      case 'fair':
        return TrustScore.fair;
      case 'good':
        return TrustScore.good;
      case 'verygood':
        return TrustScore.verygood;
      case 'excellent':
        return TrustScore.excellent;
      default:
        return TrustScore.new_;
    }
  }
}
