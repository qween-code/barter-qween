import 'package:equatable/equatable.dart';
import 'item_entity.dart';

/// Barter Match Entity
/// 
/// Represents a potential barter match between two items.
/// Contains match scoring and compatibility analysis.
class BarterMatchEntity extends Equatable {
  final String id;
  final String sourceItemId; // The item user is trying to trade
  final String targetItemId; // The potential match item
  final String sourceUserId; // Owner of source item
  final String targetUserId; // Owner of target item

  // Match scoring (0-100)
  final double matchScore; // Overall match score
  final double compatibilityScore; // Compatibility score
  final double categoryScore; // Category compatibility (0-100)
  final double priceScore; // Price similarity (0-100)
  final double locationScore; // Location proximity (0-100)
  final double trustScore; // User trust compatibility (0-100)
  final double conditionScore; // Item condition match (0-100)

  // Match details
  final MatchQuality quality; // Excellent, Good, Fair, Poor
  final List<String> matchReasons; // Why this is a good match
  final List<String>? concerns; // Potential concerns

  // Distance & location
  final double? distanceKm; // Distance between items
  final String? locationDescription; // "5 km away in Kadıköy"

  // Barter conditions compatibility
  final bool conditionsCompatible; // Do barter conditions match?
  final String? compatibilityNote; // Explanation of compatibility

  // Cash differential (if any)
  final double? suggestedCashDifferential; // Suggested cash difference
  final CashDirection? cashDirection; // Who should pay

  // Metadata
  final DateTime calculatedAt; // When match was calculated
  final bool isSeen; // Has user seen this match?
  final bool isDismissed; // Has user dismissed this match?
  final DateTime? seenAt;
  final DateTime? dismissedAt;

  // Analytics
  final int viewCount; // How many times viewed
  final bool wasOffered; // Was offer sent for this match?
  final String? offerId; // If offer was sent

  const BarterMatchEntity({
    required this.id,
    required this.sourceItemId,
    required this.targetItemId,
    required this.sourceUserId,
    required this.targetUserId,
    required this.matchScore,
    required this.compatibilityScore,
    required this.categoryScore,
    required this.priceScore,
    required this.locationScore,
    required this.trustScore,
    required this.conditionScore,
    required this.quality,
    required this.matchReasons,
    this.concerns,
    this.distanceKm,
    this.locationDescription,
    required this.conditionsCompatible,
    this.compatibilityNote,
    this.suggestedCashDifferential,
    this.cashDirection,
    required this.calculatedAt,
    this.isSeen = false,
    this.isDismissed = false,
    this.seenAt,
    this.dismissedAt,
    this.viewCount = 0,
    this.wasOffered = false,
    this.offerId,
  });

  /// Check if match is high quality (score >= 80)
  bool get isHighQuality => matchScore >= 80;

  /// Check if match is worth showing (score >= 50 and not dismissed)
  bool get isWorthShowing => matchScore >= 50 && !isDismissed;

  /// Get formatted distance string
  String get formattedDistance {
    if (distanceKm == null) return 'Konum bilinmiyor';
    if (distanceKm! < 1) return '${(distanceKm! * 1000).toInt()} m uzaklıkta';
    return '${distanceKm!.toStringAsFixed(1)} km uzaklıkta';
  }

  /// Get match quality label
  String get qualityLabel {
    switch (quality) {
      case MatchQuality.excellent:
        return 'Mükemmel Eşleşme';
      case MatchQuality.veryGood:
        return 'Çok İyi Eşleşme';
      case MatchQuality.good:
        return 'İyi Eşleşme';
      case MatchQuality.fair:
        return 'Kabul Edilebilir';
      case MatchQuality.poor:
        return 'Zayıf Eşleşme';
    }
  }

  BarterMatchEntity copyWith({
    String? id,
    String? sourceItemId,
    String? targetItemId,
    String? sourceUserId,
    String? targetUserId,
    double? matchScore,
    double? categoryScore,
    double? priceScore,
    double? locationScore,
    double? trustScore,
    double? conditionScore,
    MatchQuality? quality,
    List<String>? matchReasons,
    List<String>? concerns,
    double? distanceKm,
    String? locationDescription,
    bool? conditionsCompatible,
    String? compatibilityNote,
    double? suggestedCashDifferential,
    CashDirection? cashDirection,
    DateTime? calculatedAt,
    bool? isSeen,
    bool? isDismissed,
    DateTime? seenAt,
    DateTime? dismissedAt,
    int? viewCount,
    bool? wasOffered,
    String? offerId,
  }) {
    return BarterMatchEntity(
      id: id ?? this.id,
      sourceItemId: sourceItemId ?? this.sourceItemId,
      targetItemId: targetItemId ?? this.targetItemId,
      sourceUserId: sourceUserId ?? this.sourceUserId,
      targetUserId: targetUserId ?? this.targetUserId,
      matchScore: matchScore ?? this.matchScore,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      categoryScore: categoryScore ?? this.categoryScore,
      priceScore: priceScore ?? this.priceScore,
      locationScore: locationScore ?? this.locationScore,
      trustScore: trustScore ?? this.trustScore,
      conditionScore: conditionScore ?? this.conditionScore,
      quality: quality ?? this.quality,
      matchReasons: matchReasons ?? this.matchReasons,
      concerns: concerns ?? this.concerns,
      distanceKm: distanceKm ?? this.distanceKm,
      locationDescription: locationDescription ?? this.locationDescription,
      conditionsCompatible: conditionsCompatible ?? this.conditionsCompatible,
      compatibilityNote: compatibilityNote ?? this.compatibilityNote,
      suggestedCashDifferential:
          suggestedCashDifferential ?? this.suggestedCashDifferential,
      cashDirection: cashDirection ?? this.cashDirection,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      isSeen: isSeen ?? this.isSeen,
      isDismissed: isDismissed ?? this.isDismissed,
      seenAt: seenAt ?? this.seenAt,
      dismissedAt: dismissedAt ?? this.dismissedAt,
      viewCount: viewCount ?? this.viewCount,
      wasOffered: wasOffered ?? this.wasOffered,
      offerId: offerId ?? this.offerId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sourceItemId,
        targetItemId,
        sourceUserId,
        targetUserId,
        matchScore,
        compatibilityScore,
        categoryScore,
        priceScore,
        locationScore,
        trustScore,
        conditionScore,
        quality,
        matchReasons,
        concerns,
        distanceKm,
        locationDescription,
        conditionsCompatible,
        compatibilityNote,
        suggestedCashDifferential,
        cashDirection,
        calculatedAt,
        isSeen,
        isDismissed,
        seenAt,
        dismissedAt,
        viewCount,
        wasOffered,
        offerId,
      ];

  @override
  String toString() {
    return 'BarterMatch(score: $matchScore, quality: $quality, source: $sourceItemId, target: $targetItemId)';
  }
}

/// Match quality enum
enum MatchQuality {
  excellent, // 90-100: Perfect match
  veryGood, // 80-89: Very good match
  good, // 70-79: Good match
  fair, // 50-69: Acceptable match
  poor, // 0-49: Poor match
}

/// Cash direction for differential
enum CashDirection {
  sourceToTarget, // Source user pays target user
  targetToSource, // Target user pays source user
  fromInitiator, // From initiator
  toInitiator, // To initiator
  none, // No cash differential
}

/// Helper to calculate match quality from score
MatchQuality matchQualityFromScore(double score) {
  if (score >= 90) return MatchQuality.excellent;
  if (score >= 80) return MatchQuality.veryGood;
  if (score >= 70) return MatchQuality.good;
  if (score >= 50) return MatchQuality.fair;
  return MatchQuality.poor;
}

/// Extension for match quality
extension MatchQualityExtension on MatchQuality {
  String get emoji {
    switch (this) {
      case MatchQuality.excellent:
        return '🎯';
      case MatchQuality.veryGood:
        return '⭐';
      case MatchQuality.good:
        return '👍';
      case MatchQuality.fair:
        return '✓';
      case MatchQuality.poor:
        return '⚠️';
    }
  }

  String get color {
    switch (this) {
      case MatchQuality.excellent:
        return '#4CAF50'; // Green
      case MatchQuality.veryGood:
        return '#8BC34A'; // Light Green
      case MatchQuality.good:
        return '#FFC107'; // Amber
      case MatchQuality.fair:
        return '#FF9800'; // Orange
      case MatchQuality.poor:
        return '#F44336'; // Red
    }
  }
}

extension BarterMatchEntityExtension on BarterMatchEntity {
  static BarterMatchEntity fromJson(Map<String, dynamic> json) {
    return BarterMatchEntity(
      id: json['id'] ?? '',
      sourceItemId: json['sourceItemId'] ?? '',
      targetItemId: json['targetItemId'] ?? '',
      sourceUserId: json['sourceUserId'] ?? '',
      targetUserId: json['targetUserId'] ?? '',
      matchScore: (json['matchScore'] ?? 0).toDouble(),
      compatibilityScore: (json['compatibilityScore'] ?? 0).toDouble(),
      categoryScore: (json['categoryScore'] ?? 0).toDouble(),
      priceScore: (json['priceScore'] ?? 0).toDouble(),
      locationScore: (json['locationScore'] ?? 0).toDouble(),
      trustScore: (json['trustScore'] ?? 0).toDouble(),
      conditionScore: (json['conditionScore'] ?? 0).toDouble(),
      quality: MatchQuality.values.firstWhere(
        (e) => e.toString() == 'MatchQuality.${json['quality']}',
        orElse: () => MatchQuality.fair,
      ),
      matchReasons: List<String>.from(json['matchReasons'] ?? []),
      concerns: List<String>.from(json['concerns'] ?? []),
      distanceKm: json['distanceKm']?.toDouble(),
      locationDescription: json['locationDescription'],
      conditionsCompatible: json['conditionsCompatible'] ?? true,
      compatibilityNote: json['compatibilityNote'],
      suggestedCashDifferential: json['suggestedCashDifferential']?.toDouble(),
      cashDirection: CashDirection.values.firstWhere(
        (e) => e.toString() == 'CashDirection.${json['cashDirection']}',
        orElse: () => CashDirection.none,
      ),
      calculatedAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isSeen: json['isSeen'] ?? false,
      isDismissed: json['isDismissed'] ?? false,
      dismissedAt: json['dismissedAt'] != null ? DateTime.parse(json['dismissedAt']) : null,
      offerId: json['offerId'],
    );
  }
}
