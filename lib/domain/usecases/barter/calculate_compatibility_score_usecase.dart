import 'package:injectable/injectable.dart';
import '../../entities/item_entity.dart';
import '../../entities/barter_condition_entity.dart';

/// Calculate Compatibility Score Use Case (Sprint 3)
/// İki ilan arasında uyumluluk puanı hesaplar (0-100)
@injectable
class CalculateCompatibilityScoreUseCase {
  CalculateCompatibilityScoreUseCase();

  /// Calculate compatibility score between source item and potential match
  double call({
    required ItemEntity sourceItem,
    required ItemEntity matchItem,
  }) {
    double score = 0.0;
    int factors = 0;

    final sourceCondition = sourceItem.barterCondition;
    final matchCondition = matchItem.barterCondition;

    // Factor 1: Category Match (30 points)
    if (_isCategoryMatch(sourceItem, matchItem, sourceCondition)) {
      score += 30.0;
    } else if (_isRelatedCategory(sourceItem.category, matchItem.category)) {
      score += 15.0; // Partial points for related categories
    }
    factors++;

    // Factor 2: Tier Compatibility (25 points)
    final tierScore = _calculateTierCompatibility(sourceItem.tier, matchItem.tier);
    score += tierScore * 25.0;
    factors++;

    // Factor 3: Price Range Match (25 points)
    final priceScore = _calculatePriceCompatibility(
      sourceItem.monetaryValue ?? sourceItem.price ?? 0,
      matchItem.monetaryValue ?? matchItem.price ?? 0,
    );
    score += priceScore * 25.0;
    factors++;

    // Factor 4: Barter Type Compatibility (10 points)
    if (sourceCondition != null && matchCondition != null) {
      final barterScore = _calculateBarterTypeCompatibility(
        sourceCondition.type,
        matchCondition.type,
      );
      score += barterScore * 10.0;
    }
    factors++;

    // Factor 5: Location Proximity (10 points)
    if (sourceItem.city != null && matchItem.city != null) {
      if (sourceItem.city!.toLowerCase() == matchItem.city!.toLowerCase()) {
        score += 10.0; // Same city
      } else if (_isSameRegion(sourceItem.city!, matchItem.city!)) {
        score += 5.0; // Same region
      }
    }
    factors++;

    // Ensure score is between 0-100
    return score.clamp(0.0, 100.0);
  }

  /// Check if item category matches source barter condition
  bool _isCategoryMatch(
    ItemEntity sourceItem,
    ItemEntity matchItem,
    BarterConditionEntity? sourceCondition,
  ) {
    // If source accepts specific categories, check if match category is in list
    if (sourceCondition != null &&
        sourceCondition.acceptedCategories != null &&
        sourceCondition.acceptedCategories!.isNotEmpty) {
      return sourceCondition.acceptedCategories!.contains(matchItem.category);
    }

    // Otherwise, same category is a match
    return sourceItem.category == matchItem.category;
  }

  /// Check if categories are related (e.g., Electronics and Computers)
  bool _isRelatedCategory(String cat1, String cat2) {
    // Define related category groups
    final relatedGroups = [
      ['Electronics', 'Computers', 'Phones', 'Cameras'],
      ['Clothing', 'Shoes', 'Accessories'],
      ['Furniture', 'Home Decor', 'Kitchen'],
      ['Books', 'Music', 'Movies'],
      ['Sports', 'Outdoors', 'Fitness'],
    ];

    for (final group in relatedGroups) {
      if (group.contains(cat1) && group.contains(cat2)) {
        return true;
      }
    }
    return false;
  }

  /// Calculate tier compatibility (0.0 to 1.0)
  double _calculateTierCompatibility(ItemTier? tier1, ItemTier? tier2) {
    if (tier1 == null || tier2 == null) return 0.5; // Neutral if tiers unknown

    // Exact match
    if (tier1 == tier2) return 1.0;

    // Adjacent tiers
    final tierValues = {
      ItemTier.small: 1,
      ItemTier.medium: 2,
      ItemTier.large: 3,
    };

    final diff = (tierValues[tier1]! - tierValues[tier2]!).abs();
    if (diff == 1) return 0.7; // Adjacent tier

    return 0.3; // Non-adjacent tiers
  }

  /// Calculate price compatibility (0.0 to 1.0)
  double _calculatePriceCompatibility(double price1, double price2) {
    if (price1 == 0 || price2 == 0) return 0.5; // Neutral if price unknown

    final minPrice = price1 < price2 ? price1 : price2;
    final maxPrice = price1 > price2 ? price1 : price2;
    
    if (minPrice == 0) return 0.5;

    final ratio = maxPrice / minPrice;

    // Perfect match
    if (ratio <= 1.1) return 1.0;
    
    // Close match (within 20%)
    if (ratio <= 1.2) return 0.9;
    
    // Acceptable match (within 50%)
    if (ratio <= 1.5) return 0.7;
    
    // Fair match (within 100%)
    if (ratio <= 2.0) return 0.5;
    
    // Poor match (more than double)
    return 0.3;
  }

  /// Calculate barter type compatibility
  double _calculateBarterTypeCompatibility(
    BarterConditionType type1,
    BarterConditionType type2,
  ) {
    // Direct trade is most compatible with direct trade
    if (type1 == BarterConditionType.directTrade &&
        type2 == BarterConditionType.directTrade) {
      return 1.0;
    }

    // Cash-involved trades are compatible
    if ((type1 == BarterConditionType.tradeWithCash ||
            type1 == BarterConditionType.tradeForCash) &&
        (type2 == BarterConditionType.tradeWithCash ||
            type2 == BarterConditionType.tradeForCash)) {
      return 0.8;
    }

    // Mixed compatibility
    return 0.6;
  }

  /// Check if cities are in same region (simplified)
  bool _isSameRegion(String city1, String city2) {
    // Turkish regions (simplified)
    final regions = {
      'Marmara': ['Istanbul', 'Bursa', 'Kocaeli', 'Balıkesir', 'Tekirdağ'],
      'Ege': ['İzmir', 'Manisa', 'Aydın', 'Muğla', 'Denizli'],
      'Akdeniz': ['Antalya', 'Adana', 'Mersin', 'Hatay', 'Kahramanmaraş'],
      'İç Anadolu': ['Ankara', 'Konya', 'Kayseri', 'Eskişehir', 'Sivas'],
      'Karadeniz': ['Samsun', 'Trabzon', 'Ordu', 'Rize', 'Giresun'],
      'Doğu Anadolu': ['Erzurum', 'Van', 'Malatya', 'Elazığ', 'Ağrı'],
      'Güneydoğu': ['Gaziantep', 'Şanlıurfa', 'Diyarbakır', 'Mardin', 'Batman'],
    };

    for (final cities in regions.values) {
      if (cities.contains(city1) && cities.contains(city2)) {
        return true;
      }
    }
    return false;
  }
}
