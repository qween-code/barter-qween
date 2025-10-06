import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../entities/barter_match_entity.dart';
import '../entities/item_entity.dart';

/// Use case for calculating match score between two items
/// 
/// Multi-factor scoring algorithm:
/// - Category: 30% (same category = high score)
/// - Price: 25% (similar price = high score)
/// - Location: 20% (closer = high score)
/// - Trust: 15% (higher trust = high score)
/// - Condition: 10% (similar condition = high score)
@lazySingleton
class CalculateMatchScoreUsecase {
  CalculateMatchScoreUsecase();

  /// Execute the use case
  Future<Either<Failure, BarterMatchEntity>> call(
    CalculateScoreParams params,
  ) async {
    try {
      final source = params.sourceItem;
      final target = params.targetItem;

      // Calculate individual scores
      final categoryScore = _calculateCategoryScore(source, target);
      final priceScore = _calculatePriceScore(source, target);
      final locationScore = _calculateLocationScore(source, target);
      final trustScore = _calculateTrustScore(source, target);
      final conditionScore = _calculateConditionScore(source, target);

      // Calculate weighted overall score
      final matchScore = (categoryScore * 0.30) +
          (priceScore * 0.25) +
          (locationScore * 0.20) +
          (trustScore * 0.15) +
          (conditionScore * 0.10);

      // Determine match quality
      final quality = matchQualityFromScore(matchScore);

      // Generate match reasons
      final reasons = _generateMatchReasons(
        categoryScore,
        priceScore,
        locationScore,
        trustScore,
        conditionScore,
      );

      // Generate concerns
      final concerns = _generateConcerns(
        categoryScore,
        priceScore,
        locationScore,
        source,
        target,
      );

      // Calculate distance
      final distance = _calculateDistance(source, target);

      // Calculate cash differential suggestion
      final cashSuggestion = _calculateCashSuggestion(source, target);

      // Check conditions compatibility
      final conditionsCompatible = _checkConditionsCompatibility(source, target);

      // Create match entity
      final match = BarterMatchEntity(
        id: '${source.id}_${target.id}', // Composite ID
        sourceItemId: source.id,
        targetItemId: target.id,
        sourceUserId: source.userId,
        targetUserId: target.userId,
        matchScore: matchScore,
        compatibilityScore: matchScore, // Use matchScore as compatibilityScore
        categoryScore: categoryScore,
        priceScore: priceScore,
        locationScore: locationScore,
        trustScore: trustScore,
        conditionScore: conditionScore,
        quality: quality,
        matchReasons: reasons,
        concerns: concerns.isNotEmpty ? concerns : null,
        distanceKm: distance,
        locationDescription: _formatLocationDescription(source, target, distance),
        conditionsCompatible: conditionsCompatible,
        compatibilityNote: _generateCompatibilityNote(source, target),
        suggestedCashDifferential: cashSuggestion?['amount'] as double?,
        cashDirection: cashSuggestion?['direction'] as CashDirection?,
        calculatedAt: DateTime.now(),
      );

      return Right(match);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Calculate category compatibility score (0-100)
  double _calculateCategoryScore(ItemEntity source, ItemEntity target) {
    if (source.category == target.category) {
      return 100.0; // Perfect match
    }
    
    // Check if target accepts source's category
    if (target.barterCondition?.acceptedCategories?.contains(source.category) ?? false) {
      return 80.0;
    }

    // Related categories (could be enhanced with category hierarchy)
    return 40.0;
  }

  /// Calculate price similarity score (0-100)
  double _calculatePriceScore(ItemEntity source, ItemEntity target) {
    final sourcePrice = source.monetaryValue ?? source.price;
    final targetPrice = target.monetaryValue ?? target.price;

    if (sourcePrice == null || targetPrice == null) {
      return 50.0; // Neutral if prices not set
    }

    final priceDiff = (sourcePrice - targetPrice).abs();
    final avgPrice = (sourcePrice + targetPrice) / 2;
    final diffPercent = (priceDiff / avgPrice) * 100;

    if (diffPercent < 10) return 100.0; // Within 10%
    if (diffPercent < 20) return 80.0;
    if (diffPercent < 30) return 60.0;
    if (diffPercent < 50) return 40.0;
    return 20.0;
  }

  /// Calculate location proximity score (0-100)
  double _calculateLocationScore(ItemEntity source, ItemEntity target) {
    if (source.city == target.city) {
      // Same city - check district/neighborhood
      if (source.district == target.district) {
        return 100.0; // Same district
      }
      return 80.0; // Same city, different district
    }

    // Different cities
    final distance = _calculateDistance(source, target);
    if (distance == null) return 50.0;

    if (distance < 10) return 90.0;
    if (distance < 25) return 70.0;
    if (distance < 50) return 50.0;
    if (distance < 100) return 30.0;
    return 10.0;
  }

  /// Calculate trust compatibility score (0-100)
  double _calculateTrustScore(ItemEntity source, ItemEntity target) {
    // Based on seller ratings and verification
    // For now, use simple heuristics
    
    double score = 50.0; // Base score

    // Boost for verified users
    // TODO: Add user verification status when available
    
    // Could add: transaction history, rating, badges, etc.
    return score;
  }

  /// Calculate condition compatibility score (0-100)
  double _calculateConditionScore(ItemEntity source, ItemEntity target) {
    if (source.condition == target.condition) {
      return 100.0; // Same condition
    }

    // Similar conditions
    final conditions = ['yeni', 'sıfır ayarında', 'az kullanılmış', 'kullanılmış', 'hasarlı'];
    final sourceIndex = conditions.indexOf(source.condition ?? '');
    final targetIndex = conditions.indexOf(target.condition ?? '');

    if (sourceIndex == -1 || targetIndex == -1) return 50.0;

    final diff = (sourceIndex - targetIndex).abs();
    if (diff <= 1) return 80.0;
    if (diff <= 2) return 60.0;
    return 40.0;
  }

  /// Calculate distance between items (km)
  double? _calculateDistance(ItemEntity source, ItemEntity target) {
    if (source.latitude == null || source.longitude == null ||
        target.latitude == null || target.longitude == null) {
      return null;
    }

    // Haversine formula for distance
    const R = 6371.0; // Earth radius in km
    final lat1 = source.latitude! * pi / 180;
    final lat2 = target.latitude! * pi / 180;
    final dLat = (target.latitude! - source.latitude!) * pi / 180;
    final dLon = (target.longitude! - source.longitude!) * pi / 180;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  /// Generate match reasons
  List<String> _generateMatchReasons(
    double categoryScore,
    double priceScore,
    double locationScore,
    double trustScore,
    double conditionScore,
  ) {
    final reasons = <String>[];

    if (categoryScore >= 80) reasons.add('Aynı kategoride');
    if (priceScore >= 80) reasons.add('Benzer değerde');
    if (locationScore >= 80) reasons.add('Yakın lokasyon');
    if (conditionScore >= 80) reasons.add('Benzer durumda');

    return reasons;
  }

  /// Generate concerns
  List<String> _generateConcerns(
    double categoryScore,
    double priceScore,
    double locationScore,
    ItemEntity source,
    ItemEntity target,
  ) {
    final concerns = <String>[];

    if (priceScore < 50) {
      concerns.add('Fiyat farkı yüksek (para farkı gerekebilir)');
    }
    if (locationScore < 50) {
      concerns.add('Uzak mesafe (buluşma zorluğu)');
    }
    if (categoryScore < 50) {
      concerns.add('Farklı kategoriler');
    }

    return concerns;
  }

  /// Calculate cash differential suggestion
  Map<String, dynamic>? _calculateCashSuggestion(ItemEntity source, ItemEntity target) {
    final sourcePrice = source.monetaryValue ?? source.price;
    final targetPrice = target.monetaryValue ?? target.price;

    if (sourcePrice == null || targetPrice == null) return null;

    final diff = (sourcePrice - targetPrice).abs();
    if (diff < (sourcePrice * 0.1)) return null; // No suggestion if within 10%

    return {
      'amount': diff,
      'direction': sourcePrice > targetPrice
          ? CashDirection.targetToSource // Target pays source
          : CashDirection.sourceToTarget, // Source pays target
    };
  }

  /// Check barter conditions compatibility
  bool _checkConditionsCompatibility(ItemEntity source, ItemEntity target) {
    final targetCondition = target.barterCondition;
    if (targetCondition == null) return true; // No conditions = compatible

    // Check accepted categories
    if (targetCondition.acceptedCategories != null &&
        targetCondition.acceptedCategories!.isNotEmpty) {
      if (!targetCondition.acceptedCategories!.contains(source.category)) {
        return false;
      }
    }

    // Check value range
    final sourceValue = source.monetaryValue ?? source.price;
    if (sourceValue != null) {
      if (targetCondition.minValue != null && sourceValue < targetCondition.minValue!) {
        return false;
      }
      if (targetCondition.maxValue != null && sourceValue > targetCondition.maxValue!) {
        return false;
      }
    }

    return true;
  }

  /// Generate compatibility note
  String? _generateCompatibilityNote(ItemEntity source, ItemEntity target) {
    if (!_checkConditionsCompatibility(source, target)) {
      return 'Takas şartları tam olarak uyuşmuyor';
    }
    return null;
  }

  /// Format location description
  String? _formatLocationDescription(ItemEntity source, ItemEntity target, double? distance) {
    if (source.city == target.city) {
      return 'Aynı şehir: ${target.city}';
    }
    if (distance != null) {
      return '${distance.toStringAsFixed(1)} km uzaklıkta';
    }
    return target.city;
  }
}

/// Parameters for calculating match score
class CalculateScoreParams {
  final ItemEntity sourceItem;
  final ItemEntity targetItem;

  CalculateScoreParams({
    required this.sourceItem,
    required this.targetItem,
  });
}
