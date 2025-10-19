import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/barter_match_entity.dart';

/// Barter Match Model for Firestore serialization
class BarterMatchModel {
  final String id;
  final String sourceItemId;
  final String targetItemId;
  final String sourceUserId;
  final String targetUserId;
  final double matchScore;
  final double categoryScore;
  final double priceScore;
  final double locationScore;
  final double trustScore;
  final double conditionScore;
  final String quality;
  final List<String> matchReasons;
  final List<String>? concerns;
  final double? distanceKm;
  final String? locationDescription;
  final bool conditionsCompatible;
  final String? compatibilityNote;
  final double? suggestedCashDifferential;
  final String? cashDirection;
  final DateTime calculatedAt;
  final bool isSeen;
  final bool isDismissed;
  final DateTime? seenAt;
  final DateTime? dismissedAt;
  final int viewCount;
  final bool wasOffered;
  final String? offerId;

  BarterMatchModel({
    required this.id,
    required this.sourceItemId,
    required this.targetItemId,
    required this.sourceUserId,
    required this.targetUserId,
    required this.matchScore,
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

  /// Convert from Entity to Model
  factory BarterMatchModel.fromEntity(BarterMatchEntity entity) {
    return BarterMatchModel(
      id: entity.id,
      sourceItemId: entity.sourceItemId,
      targetItemId: entity.targetItemId,
      sourceUserId: entity.sourceUserId,
      targetUserId: entity.targetUserId,
      matchScore: entity.matchScore,
      categoryScore: entity.categoryScore,
      priceScore: entity.priceScore,
      locationScore: entity.locationScore,
      trustScore: entity.trustScore,
      conditionScore: entity.conditionScore,
      quality: entity.quality.name,
      matchReasons: entity.matchReasons,
      concerns: entity.concerns,
      distanceKm: entity.distanceKm,
      locationDescription: entity.locationDescription,
      conditionsCompatible: entity.conditionsCompatible,
      compatibilityNote: entity.compatibilityNote,
      suggestedCashDifferential: entity.suggestedCashDifferential,
      cashDirection: entity.cashDirection?.name,
      calculatedAt: entity.calculatedAt,
      isSeen: entity.isSeen,
      isDismissed: entity.isDismissed,
      seenAt: entity.seenAt,
      dismissedAt: entity.dismissedAt,
      viewCount: entity.viewCount,
      wasOffered: entity.wasOffered,
      offerId: entity.offerId,
    );
  }

  /// Convert from Firestore DocumentSnapshot
  factory BarterMatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BarterMatchModel(
      id: doc.id,
      sourceItemId: data['sourceItemId'] as String,
      targetItemId: data['targetItemId'] as String,
      sourceUserId: data['sourceUserId'] as String,
      targetUserId: data['targetUserId'] as String,
      matchScore: (data['matchScore'] as num).toDouble(),
      categoryScore: (data['categoryScore'] as num).toDouble(),
      priceScore: (data['priceScore'] as num).toDouble(),
      locationScore: (data['locationScore'] as num).toDouble(),
      trustScore: (data['trustScore'] as num).toDouble(),
      conditionScore: (data['conditionScore'] as num).toDouble(),
      quality: data['quality'] as String,
      matchReasons: List<String>.from(data['matchReasons'] as List),
      concerns: data['concerns'] != null
          ? List<String>.from(data['concerns'] as List)
          : null,
      distanceKm: (data['distanceKm'] as num?)?.toDouble(),
      locationDescription: data['locationDescription'] as String?,
      conditionsCompatible: data['conditionsCompatible'] as bool,
      compatibilityNote: data['compatibilityNote'] as String?,
      suggestedCashDifferential: (data['suggestedCashDifferential'] as num?)
          ?.toDouble(),
      cashDirection: data['cashDirection'] as String?,
      calculatedAt: (data['calculatedAt'] as Timestamp).toDate(),
      isSeen: data['isSeen'] as bool? ?? false,
      isDismissed: data['isDismissed'] as bool? ?? false,
      seenAt: data['seenAt'] != null
          ? (data['seenAt'] as Timestamp).toDate()
          : null,
      dismissedAt: data['dismissedAt'] != null
          ? (data['dismissedAt'] as Timestamp).toDate()
          : null,
      viewCount: data['viewCount'] as int? ?? 0,
      wasOffered: data['wasOffered'] as bool? ?? false,
      offerId: data['offerId'] as String?,
    );
  }

  /// Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'sourceItemId': sourceItemId,
      'targetItemId': targetItemId,
      'sourceUserId': sourceUserId,
      'targetUserId': targetUserId,
      'matchScore': matchScore,
      'categoryScore': categoryScore,
      'priceScore': priceScore,
      'locationScore': locationScore,
      'trustScore': trustScore,
      'conditionScore': conditionScore,
      'quality': quality,
      'matchReasons': matchReasons,
      'concerns': concerns,
      'distanceKm': distanceKm,
      'locationDescription': locationDescription,
      'conditionsCompatible': conditionsCompatible,
      'compatibilityNote': compatibilityNote,
      'suggestedCashDifferential': suggestedCashDifferential,
      'cashDirection': cashDirection,
      'calculatedAt': Timestamp.fromDate(calculatedAt),
      'isSeen': isSeen,
      'isDismissed': isDismissed,
      'seenAt': seenAt != null ? Timestamp.fromDate(seenAt!) : null,
      'dismissedAt': dismissedAt != null
          ? Timestamp.fromDate(dismissedAt!)
          : null,
      'viewCount': viewCount,
      'wasOffered': wasOffered,
      'offerId': offerId,
    };
  }

  /// Convert to Entity
  BarterMatchEntity toEntity() {
    return BarterMatchEntity(
      id: id,
      sourceItemId: sourceItemId,
      targetItemId: targetItemId,
      sourceUserId: sourceUserId,
      targetUserId: targetUserId,
      matchScore: matchScore,
      compatibilityScore: matchScore, // Use matchScore as compatibilityScore
      categoryScore: categoryScore,
      priceScore: priceScore,
      locationScore: locationScore,
      trustScore: trustScore,
      conditionScore: conditionScore,
      quality: MatchQuality.values.firstWhere((e) => e.name == quality),
      matchReasons: matchReasons,
      concerns: concerns,
      distanceKm: distanceKm,
      locationDescription: locationDescription,
      conditionsCompatible: conditionsCompatible,
      compatibilityNote: compatibilityNote,
      suggestedCashDifferential: suggestedCashDifferential,
      cashDirection: cashDirection != null
          ? CashDirection.values.firstWhere((e) => e.name == cashDirection)
          : null,
      calculatedAt: calculatedAt,
      isSeen: isSeen,
      isDismissed: isDismissed,
      seenAt: seenAt,
      dismissedAt: dismissedAt,
      viewCount: viewCount,
      wasOffered: wasOffered,
      offerId: offerId,
    );
  }
}
