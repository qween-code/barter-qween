import 'dart:math';
import '../../domain/entities/item_entity.dart';
import '../../domain/entities/barter_match_entity.dart';
import '../../domain/entities/user_entity.dart';
import 'map_service.dart';
import 'analytics_service.dart';
import '../di/injection.dart';

/// Advanced Barter Matching Service
///
/// Provides sophisticated matching algorithms with ML preparation,
/// advanced filtering, and intelligent scoring systems.
class BarterMatchingService {
  final MapService _mapService = getIt<MapService>();
  final AnalyticsService _analyticsService = getIt<AnalyticsService>();

  /// Enhanced matching algorithm with ML preparation
  ///
  /// This algorithm prepares data for future ML models while providing
  /// sophisticated matching based on multiple factors.
  Future<BarterMatchEntity> calculateEnhancedMatch({
    required ItemEntity sourceItem,
    required ItemEntity targetItem,
    required UserEntity sourceUser,
    required UserEntity targetUser,
  }) async {
    // 1. Basic compatibility check
    if (!_isBasicCompatible(sourceItem, targetItem)) {
      throw Exception('Items are not compatible for barter');
    }

    // 2. Calculate detailed scores
    final scores = await _calculateDetailedScores(
      sourceItem: sourceItem,
      targetItem: targetItem,
      sourceUser: sourceUser,
      targetUser: targetUser,
    );

    // 3. Generate match insights
    final insights = _generateMatchInsights(scores, sourceItem, targetItem);

    // 4. Prepare ML data structure
    final mlData = _prepareMLData(
      scores,
      sourceItem,
      targetItem,
      sourceUser,
      targetUser,
    );

    // 5. Calculate final match score with ML preparation
    final finalScore = _calculateFinalScore(scores, insights);

    // 6. Determine match quality
    final quality = _determineMatchQuality(finalScore, insights);

    // 7. Generate match reasons and concerns
    final matchReasons = _generateMatchReasons(scores, insights);
    final concerns = _generateConcerns(scores, insights);

    // 8. Calculate distance
    final distanceKm = await _calculateDistance(sourceItem, targetItem);

    // 9. Calculate cash differential
    final cashDifferential = _calculateCashDifferential(
      sourceItem.price,
      targetItem.price,
    );

    // 10. Log analytics for ML training
    await _logMLTrainingData(mlData, finalScore);

    return BarterMatchEntity(
      id: '${sourceItem.id}_${targetItem.id}',
      sourceItemId: sourceItem.id,
      targetItemId: targetItem.id,
      sourceUserId: sourceItem.ownerId,
      targetUserId: targetItem.ownerId,

      // Enhanced scoring
      matchScore: finalScore,
      categoryScore: scores['category']!,
      priceScore: scores['price']!,
      locationScore: scores['location']!,
      trustScore: scores['trust']!,
      conditionScore: scores['condition']!,

      // Additional scores for ML
      compatibilityScore: scores['compatibility']!,

      // Match details
      quality: quality,
      matchReasons: matchReasons,
      concerns: concerns.isNotEmpty ? concerns : null,

      // Distance & location
      distanceKm: distanceKm,
      locationDescription: distanceKm != null
          ? '${distanceKm.toStringAsFixed(1)} km away'
          : null,

      // Barter conditions compatibility
      conditionsCompatible: insights['conditionsCompatible'] ?? true,
      compatibilityNote:
          insights['compatibilityNote'] ?? 'Barter conditions compatible',

      // Cash differential
      suggestedCashDifferential: cashDifferential,
      cashDirection: null, // TODO: Fix CashDirection mapping
      // ML insights
      // matchInsights: insights, // TODO: Add matchInsights property to BarterMatchEntity

      // Metadata
      calculatedAt: DateTime.now(),
      isSeen: false,
      isDismissed: false,
      viewCount: 0,
      wasOffered: false,
    );
  }

  /// Advanced filtering system
  ///
  /// Provides sophisticated filtering options for barter matches
  List<BarterMatchEntity> filterMatches({
    required List<BarterMatchEntity> matches,
    MatchQuality? qualityFilter,
    double? minScore,
    double? maxDistance,
    List<String>? categoryFilter,
    bool? hasCashDifferential,
    CashDirection? cashDirection,
    DateTime? fromDate,
    DateTime? toDate,
    List<String>? excludeUsers,
  }) {
    return matches.where((match) {
      // Quality filter
      if (qualityFilter != null && match.quality != qualityFilter) {
        return false;
      }

      // Score filter
      if (minScore != null && match.matchScore < minScore) {
        return false;
      }

      // Distance filter
      if (maxDistance != null &&
          match.distanceKm != null &&
          match.distanceKm! > maxDistance) {
        return false;
      }

      // Category filter (would need item data)
      // if (categoryFilter != null && !categoryFilter.contains(match.category)) {
      //   return false;
      // }

      // Cash differential filter
      if (hasCashDifferential != null) {
        final hasCash = match.suggestedCashDifferential != null;
        if (hasCashDifferential && !hasCash) return false;
        if (!hasCashDifferential && hasCash) return false;
      }

      // Cash direction filter
      if (cashDirection != null && match.cashDirection != cashDirection) {
        return false;
      }

      // Date range filter
      if (fromDate != null && match.calculatedAt.isBefore(fromDate)) {
        return false;
      }
      if (toDate != null && match.calculatedAt.isAfter(toDate)) {
        return false;
      }

      // Exclude users filter
      if (excludeUsers != null &&
          (excludeUsers.contains(match.sourceUserId) ||
              excludeUsers.contains(match.targetUserId))) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Sort matches by various criteria
  List<BarterMatchEntity> sortMatches({
    required List<BarterMatchEntity> matches,
    required BarterSortCriteria criteria,
    bool ascending = false,
  }) {
    final sortedMatches = List<BarterMatchEntity>.from(matches);

    switch (criteria) {
      case BarterSortCriteria.bestMatch:
        sortedMatches.sort(
          (a, b) => ascending
              ? a.matchScore.compareTo(b.matchScore)
              : b.matchScore.compareTo(a.matchScore),
        );
        break;
      case BarterSortCriteria.newest:
        sortedMatches.sort(
          (a, b) => ascending
              ? a.calculatedAt.compareTo(b.calculatedAt)
              : b.calculatedAt.compareTo(a.calculatedAt),
        );
        break;
      case BarterSortCriteria.distance:
        sortedMatches.sort((a, b) {
          final aDistance = a.distanceKm ?? double.infinity;
          final bDistance = b.distanceKm ?? double.infinity;
          return ascending
              ? aDistance.compareTo(bDistance)
              : bDistance.compareTo(aDistance);
        });
        break;
      case BarterSortCriteria.priceDifference:
        sortedMatches.sort((a, b) {
          final aDiff = a.suggestedCashDifferential ?? 0;
          final bDiff = b.suggestedCashDifferential ?? 0;
          return ascending ? aDiff.compareTo(bDiff) : bDiff.compareTo(aDiff);
        });
        break;
      case BarterSortCriteria.trustScore:
        sortedMatches.sort(
          (a, b) => ascending
              ? a.trustScore.compareTo(b.trustScore)
              : b.trustScore.compareTo(a.trustScore),
        );
        break;
    }

    return sortedMatches;
  }

  /// Calculate detailed scores for ML preparation
  Future<Map<String, double>> _calculateDetailedScores({
    required ItemEntity sourceItem,
    required ItemEntity targetItem,
    required UserEntity sourceUser,
    required UserEntity targetUser,
  }) async {
    final scores = <String, double>{};

    // 1. Category Score (30% weight)
    scores['category'] = _calculateCategoryScore(sourceItem, targetItem);

    // 2. Price Score (25% weight)
    scores['price'] = _calculatePriceScore(sourceItem.price, targetItem.price);

    // 3. Location Score (20% weight)
    scores['location'] = await _calculateLocationScore(sourceItem, targetItem);

    // 4. Trust Score (15% weight)
    scores['trust'] = _calculateTrustScore(sourceUser, targetUser);

    // 5. Condition Score (10% weight)
    scores['condition'] = _calculateConditionScore(sourceItem, targetItem);

    // 6. Compatibility Score (new)
    scores['compatibility'] = _calculateCompatibilityScore(
      sourceItem,
      targetItem,
    );

    // 7. Demand Score (new)
    scores['demand'] = await _calculateDemandScore(targetItem);

    // 8. Seasonality Score (new)
    scores['seasonality'] = _calculateSeasonalityScore(sourceItem, targetItem);

    // 9. User Preference Score (new)
    scores['userPreference'] = _calculateUserPreferenceScore(
      sourceUser,
      targetItem,
    );

    return scores;
  }

  /// Basic compatibility check
  bool _isBasicCompatible(ItemEntity sourceItem, ItemEntity targetItem) {
    // Same owner check
    if (sourceItem.ownerId == targetItem.ownerId) return false;

    // Status check
    if (sourceItem.status != ItemStatus.active ||
        targetItem.status != ItemStatus.active) {
      return false;
    }

    // Barter condition check
    if (sourceItem.barterCondition == null ||
        targetItem.barterCondition == null) {
      return false;
    }

    return true;
  }

  /// Calculate category score with ML preparation
  double _calculateCategoryScore(ItemEntity sourceItem, ItemEntity targetItem) {
    // Exact category match
    if (sourceItem.category == targetItem.category) {
      return 100.0;
    }

    // Subcategory match
    if (sourceItem.subcategory == targetItem.subcategory) {
      return 80.0;
    }

    // Related categories (for ML training)
    final relatedCategories = _getRelatedCategories(sourceItem.category);
    if (relatedCategories.contains(targetItem.category)) {
      return 60.0;
    }

    // Completely different categories
    return 20.0;
  }

  /// Calculate price score with market analysis
  double _calculatePriceScore(double? sourcePrice, double? targetPrice) {
    if (sourcePrice == null ||
        targetPrice == null ||
        sourcePrice == 0 ||
        targetPrice == 0) {
      return 50.0; // Neutral score
    }

    final priceDiff =
        (sourcePrice - targetPrice).abs() / max(sourcePrice, targetPrice);

    // High score for similar prices
    if (priceDiff <= 0.1) return 100.0;
    if (priceDiff <= 0.2) return 80.0;
    if (priceDiff <= 0.3) return 60.0;
    if (priceDiff <= 0.5) return 40.0;

    return 20.0;
  }

  /// Calculate location score
  Future<double> _calculateLocationScore(
    ItemEntity sourceItem,
    ItemEntity targetItem,
  ) async {
    if (sourceItem.latitude == null ||
        sourceItem.longitude == null ||
        targetItem.latitude == null ||
        targetItem.longitude == null) {
      return 50.0; // Neutral if no location data
    }

    try {
      final distance = await _mapService.calculateDistance(
        sourceItem.latitude!,
        sourceItem.longitude!,
        targetItem.latitude!,
        targetItem.longitude!,
      );

      // Distance-based scoring
      if (distance <= 5) return 100.0;
      if (distance <= 15) return 80.0;
      if (distance <= 30) return 60.0;
      if (distance <= 50) return 40.0;

      return 20.0;
    } catch (e) {
      return 50.0; // Default on error
    }
  }

  /// Calculate trust score
  double _calculateTrustScore(UserEntity sourceUser, UserEntity targetUser) {
    final sourceTrust = sourceUser.trustScore ?? 50.0;
    final targetTrust = targetUser.trustScore ?? 50.0;

    // Average trust score
    return (sourceTrust + targetTrust) / 2;
  }

  /// Calculate condition score
  double _calculateConditionScore(
    ItemEntity sourceItem,
    ItemEntity targetItem,
  ) {
    if (sourceItem.condition == targetItem.condition) {
      return 100.0;
    }

    // Condition hierarchy for ML training
    final conditionHierarchy = {
      'Brand New': 100,
      'Like New': 90,
      'Good': 70,
      'Fair': 50,
      'Poor': 30,
    };

    final sourceLevel = conditionHierarchy[sourceItem.condition] ?? 50;
    final targetLevel = conditionHierarchy[targetItem.condition] ?? 50;

    final diff = (sourceLevel - targetLevel).abs();
    return max(0, 100 - diff * 2);
  }

  /// Calculate compatibility score (new)
  double _calculateCompatibilityScore(
    ItemEntity sourceItem,
    ItemEntity targetItem,
  ) {
    // Barter condition compatibility
    final sourceCondition = sourceItem.barterCondition;
    final targetCondition = targetItem.barterCondition;

    if (sourceCondition == null || targetCondition == null) return 0.0;

    double compatibility = 0.0;

    // Category compatibility
    if (sourceCondition.categories?.contains(targetItem.category) == true) {
      compatibility += 40.0;
    }

    // Condition compatibility
    if (sourceCondition.condition == targetItem.condition) {
      compatibility += 30.0;
    }

    // Cash differential compatibility
    final sourcePrice = sourceItem.price ?? 0;
    final targetPrice = targetItem.price ?? 0;
    final priceDiff = (sourcePrice - targetPrice).abs();

    if (sourceCondition.maxCashDifferential != null &&
        priceDiff <= sourceCondition.maxCashDifferential!) {
      compatibility += 30.0;
    }

    return min(100.0, compatibility);
  }

  /// Calculate demand score (new)
  Future<double> _calculateDemandScore(ItemEntity item) async {
    // This would typically query analytics data
    // For now, return a mock score based on category
    final demandScores = {
      'Electronics': 85.0,
      'Fashion': 75.0,
      'Books': 60.0,
      'Sports': 70.0,
      'Home': 65.0,
      'Toys': 55.0,
    };

    return demandScores[item.category] ?? 50.0;
  }

  /// Calculate seasonality score (new)
  double _calculateSeasonalityScore(
    ItemEntity sourceItem,
    ItemEntity targetItem,
  ) {
    final now = DateTime.now();
    final month = now.month;

    // Seasonal categories
    final seasonalCategories = {
      'Sports': [6, 7, 8], // Summer sports
      'Fashion': [3, 4, 5, 9, 10, 11], // Spring/Fall fashion
      'Home': [12, 1, 2], // Winter home items
    };

    double score = 50.0; // Base score

    for (final category in seasonalCategories.keys) {
      if (sourceItem.category == category || targetItem.category == category) {
        if (seasonalCategories[category]!.contains(month)) {
          score += 20.0;
        }
      }
    }

    return min(100.0, score);
  }

  /// Calculate user preference score (new)
  double _calculateUserPreferenceScore(UserEntity user, ItemEntity item) {
    // This would typically use user's browsing history, favorites, etc.
    // For now, return a mock score
    return 50.0 + (Random().nextDouble() * 30); // 50-80 range
  }

  /// Generate match insights for ML
  Map<String, dynamic> _generateMatchInsights(
    Map<String, double> scores,
    ItemEntity sourceItem,
    ItemEntity targetItem,
  ) {
    return {
      'conditionsCompatible': scores['compatibility']! > 70,
      'compatibilityNote': scores['compatibility']! > 70
          ? 'Barter conditions highly compatible'
          : 'Barter conditions partially compatible',
      'marketDemand': scores['demand']! > 70
          ? 'High demand item'
          : 'Standard demand',
      'seasonalMatch': scores['seasonality']! > 70
          ? 'Seasonal match'
          : 'Regular match',
      'userPreferenceMatch': scores['userPreference']! > 70
          ? 'User preference match'
          : 'Neutral',
    };
  }

  /// Prepare ML data structure
  Map<String, dynamic> _prepareMLData(
    Map<String, double> scores,
    ItemEntity sourceItem,
    ItemEntity targetItem,
    UserEntity sourceUser,
    UserEntity targetUser,
  ) {
    return {
      'features': {
        'category_match': scores['category']!,
        'price_similarity': scores['price']!,
        'location_proximity': scores['location']!,
        'trust_level': scores['trust']!,
        'condition_match': scores['condition']!,
        'compatibility': scores['compatibility']!,
        'demand_level': scores['demand']!,
        'seasonality': scores['seasonality']!,
        'user_preference': scores['userPreference']!,
      },
      'metadata': {
        'source_category': sourceItem.category,
        'target_category': targetItem.category,
        'source_condition': sourceItem.condition,
        'target_condition': targetItem.condition,
        'source_price': sourceItem.price,
        'target_price': targetItem.price,
        'source_user_trust': sourceUser.trustScore,
        'target_user_trust': targetUser.trustScore,
        'timestamp': DateTime.now().toIso8601String(),
      },
    };
  }

  /// Calculate final score with ML preparation
  double _calculateFinalScore(
    Map<String, double> scores,
    Map<String, dynamic> insights,
  ) {
    // Weighted combination of all scores
    final weights = {
      'category': 0.25,
      'price': 0.20,
      'location': 0.15,
      'trust': 0.10,
      'condition': 0.10,
      'compatibility': 0.10,
      'demand': 0.05,
      'seasonality': 0.03,
      'userPreference': 0.02,
    };

    double finalScore = 0.0;
    for (final entry in weights.entries) {
      finalScore += scores[entry.key]! * entry.value;
    }

    return min(100.0, max(0.0, finalScore));
  }

  /// Determine match quality
  MatchQuality _determineMatchQuality(
    double score,
    Map<String, dynamic> insights,
  ) {
    if (score >= 85) return MatchQuality.excellent;
    if (score >= 70) return MatchQuality.good;
    if (score >= 55) return MatchQuality.fair;
    return MatchQuality.poor;
  }

  /// Generate match reasons
  List<String> _generateMatchReasons(
    Map<String, double> scores,
    Map<String, dynamic> insights,
  ) {
    final reasons = <String>[];

    if (scores['category']! >= 80) {
      reasons.add('Same category');
    }
    if (scores['price']! >= 70) {
      reasons.add('Similar price range');
    }
    if (scores['location']! >= 80) {
      reasons.add('Close location');
    }
    if (scores['trust']! >= 80) {
      reasons.add('High trust users');
    }
    if (scores['condition']! >= 80) {
      reasons.add('Matching condition');
    }
    if (scores['compatibility']! >= 70) {
      reasons.add('Barter conditions compatible');
    }
    if (scores['demand']! >= 70) reasons.add('High demand item');
    if (scores['seasonality']! >= 70) reasons.add('Seasonal match');
    if (scores['userPreference']! >= 70) reasons.add('User preference match');

    return reasons;
  }

  /// Generate concerns
  List<String> _generateConcerns(
    Map<String, double> scores,
    Map<String, dynamic> insights,
  ) {
    final concerns = <String>[];

    if (scores['price']! < 50) {
      concerns.add('Significant price difference');
    }
    if (scores['location']! < 50) {
      concerns.add('Far distance for meetup');
    }
    if (scores['trust']! < 50) {
      concerns.add('Lower trust scores');
    }
    if (scores['compatibility']! < 50) {
      concerns.add('Barter conditions not well matched');
    }
    if (scores['demand']! < 50) concerns.add('Low demand item');

    return concerns;
  }

  /// Calculate distance between items
  Future<double?> _calculateDistance(
    ItemEntity sourceItem,
    ItemEntity targetItem,
  ) async {
    if (sourceItem.latitude == null ||
        sourceItem.longitude == null ||
        targetItem.latitude == null ||
        targetItem.longitude == null) {
      return null;
    }

    try {
      return await _mapService.calculateDistance(
        sourceItem.latitude!,
        sourceItem.longitude!,
        targetItem.latitude!,
        targetItem.longitude!,
      );
    } catch (e) {
      return null;
    }
  }

  /// Calculate cash differential
  double? _calculateCashDifferential(double? sourcePrice, double? targetPrice) {
    if (sourcePrice == null || targetPrice == null) return null;

    final diff = (sourcePrice - targetPrice).abs();
    return diff > 50 ? diff : null; // Only suggest if difference > ₺50
  }

  /// Get related categories for ML training
  List<String> _getRelatedCategories(String category) {
    final relatedCategories = {
      'Electronics': ['Technology', 'Gadgets'],
      'Fashion': ['Clothing', 'Accessories'],
      'Books': ['Education', 'Media'],
      'Sports': ['Fitness', 'Outdoor'],
      'Home': ['Furniture', 'Decor'],
      'Toys': ['Games', 'Children'],
    };

    return relatedCategories[category] ?? [];
  }

  /// Log ML training data
  Future<void> _logMLTrainingData(
    Map<String, dynamic> mlData,
    double finalScore,
  ) async {
    try {
      await _analyticsService.logEvent(
        name: 'barter_match_ml_data',
        parameters: {
          'features': mlData['features'],
          'metadata': mlData['metadata'],
          'final_score': finalScore,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Log error but don't fail the matching process
      print('Failed to log ML training data: $e');
    }
  }
}

/// Barter sort criteria enum
enum BarterSortCriteria {
  bestMatch,
  newest,
  distance,
  priceDifference,
  trustScore,
}
