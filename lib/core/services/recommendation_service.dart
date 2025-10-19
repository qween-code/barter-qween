import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/item_entity.dart';
import '../../data/models/item_model.dart';
import 'map_service.dart';

/// Recommendation Service - Phase 2 Quick Win #2
///
/// Provides simple but effective item recommendations based on:
/// - Category similarity
/// - Price range
/// - Location proximity
/// - Seller history
@LazySingleton()
class RecommendationService {
  final FirebaseFirestore _firestore;
  final MapService _mapService;

  RecommendationService(this._firestore, this._mapService);

  // ========================================
  // SIMILAR ITEMS RECOMMENDATIONS
  // ========================================

  /// Get similar items based on category, price, and location
  Future<List<ItemEntity>> getSimilarItems({
    required ItemEntity sourceItem,
    int limit = 10,
    double maxDistanceKm = 50.0,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('items')
          .where('category', isEqualTo: sourceItem.category)
          .limit(limit * 3) // Get more for filtering
          .get();

      final items = querySnapshot.docs
          .map((doc) => ItemModel.fromFirestore(doc).toEntity())
          .where((item) => item.status == ItemStatus.active)
          .where((item) => item.id != sourceItem.id)
          .toList();

      // Filter by price range (±30%)
      final sourcePrice = sourceItem.price;
      if (sourcePrice == null) return [];

      final priceMin = sourcePrice * 0.7;
      final priceMax = sourcePrice * 1.3;

      final filteredItems = items.where((item) {
        final itemPrice = item.price;
        if (itemPrice == null) return false;
        return itemPrice >= priceMin && itemPrice <= priceMax;
      }).toList();

      // Filter by distance if both have coordinates
      List<ItemEntity> nearbyItems = filteredItems;
      if (sourceItem.latitude != null && sourceItem.longitude != null) {
        final validItems = <ItemEntity>[];
        for (final item in filteredItems) {
          if (item.latitude == null || item.longitude == null) {
            validItems.add(item);
            continue;
          }

          final distance = await _mapService.calculateDistance(
            sourceItem.latitude!,
            sourceItem.longitude!,
            item.latitude!,
            item.longitude!,
          );

          if (distance <= maxDistanceKm) {
            validItems.add(item);
          }
        }
        nearbyItems = validItems;
      }

      // Sort by price similarity
      nearbyItems.sort((a, b) {
        final aPrice = a.price ?? 0.0;
        final bPrice = b.price ?? 0.0;
        final diffA = (aPrice - sourcePrice).abs();
        final diffB = (bPrice - sourcePrice).abs();
        return diffA.compareTo(diffB);
      });

      return nearbyItems.take(limit).toList();
    } catch (e) {
      print('Error getting similar items: $e');
      return [];
    }
  }

  // ========================================
  // MORE FROM SELLER
  // ========================================

  /// Get more items from the same seller
  Future<List<ItemEntity>> getMoreFromSeller({
    required String sellerId,
    String? excludeItemId,
    int limit = 6,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('items')
          .where('ownerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .limit(limit * 2)
          .get();

      final items = querySnapshot.docs
          .map((doc) => ItemModel.fromFirestore(doc).toEntity())
          .where((item) => item.status == ItemStatus.active)
          .where((item) => excludeItemId == null || item.id != excludeItemId)
          .toList();

      return items.take(limit).toList();
    } catch (e) {
      print('Error getting more from seller: $e');
      return [];
    }
  }

  // ========================================
  // NEARBY ITEMS
  // ========================================

  /// Get nearby items based on user's location
  Future<List<ItemEntity>> getNearbyItems({
    required double userLat,
    required double userLon,
    String? category,
    double radiusKm = 10.0,
    int limit = 20,
  }) async {
    try {
      // Calculate simple latitude bounding box (longitude filtering applied
      // later with precise distance calculation to avoid composite indexes).
      const double kmPerDegree = 111.0; // Approximate
      final latDelta = radiusKm / kmPerDegree;

      var query = _firestore
          .collection('items')
          .where('latitude', isGreaterThan: userLat - latDelta)
          .where('latitude', isLessThan: userLat + latDelta);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final querySnapshot = await query.limit(limit * 3).get();

      final allItems = querySnapshot.docs
          .map((doc) => ItemModel.fromFirestore(doc).toEntity())
          .where((item) => item.status == ItemStatus.active)
          .toList();

      final items = <ItemEntity>[];
      for (final item in allItems) {
        if (item.latitude == null || item.longitude == null) continue;

        final distance = await _mapService.calculateDistance(
          userLat,
          userLon,
          item.latitude!,
          item.longitude!,
        );

        if (distance <= radiusKm) {
          items.add(item);
        }
      }

      // Sort by distance
      final itemsWithDistance = <MapEntry<ItemEntity, double>>[];
      for (final item in items) {
        final distance = await _mapService.calculateDistance(
          userLat,
          userLon,
          item.latitude!,
          item.longitude!,
        );
        itemsWithDistance.add(MapEntry(item, distance));
      }

      itemsWithDistance.sort((a, b) => a.value.compareTo(b.value));
      final sortedItems = itemsWithDistance.map((entry) => entry.key).toList();

      return sortedItems.take(limit).toList();
    } catch (e) {
      print('Error getting nearby items: $e');
      return [];
    }
  }

  // ========================================
  // RECENTLY VIEWED (Requires user tracking)
  // ========================================

  /// Get recently viewed items for a user
  /// Note: This requires tracking viewed items in user's document
  Future<List<ItemEntity>> getRecentlyViewed({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) return [];

      final recentlyViewedIds =
          (userDoc.data()?['recentlyViewed'] as List?)?.cast<String>() ?? [];

      if (recentlyViewedIds.isEmpty) return [];

      // Get items in chunks (Firestore 'in' query limit is 10)
      final chunks = <List<String>>[];
      for (var i = 0; i < recentlyViewedIds.length; i += 10) {
        chunks.add(recentlyViewedIds.skip(i).take(10).toList());
      }

      final items = <ItemEntity>[];
      for (final chunk in chunks) {
        final querySnapshot = await _firestore
            .collection('items')
            .where('id', whereIn: chunk)
            .get();

        items.addAll(
          querySnapshot.docs
              .map((doc) => ItemModel.fromFirestore(doc).toEntity())
              .where((item) => item.status == ItemStatus.active),
        );

        if (items.length >= limit) break;
      }

      // Maintain order of recently viewed
      items.sort((a, b) {
        final indexA = recentlyViewedIds.indexOf(a.id);
        final indexB = recentlyViewedIds.indexOf(b.id);
        return indexA.compareTo(indexB);
      });

      return items.take(limit).toList();
    } catch (e) {
      print('Error getting recently viewed: $e');
      return [];
    }
  }

  // ========================================
  // CATEGORY-BASED RECOMMENDATIONS
  // ========================================

  /// Get popular items in a category
  Future<List<ItemEntity>> getPopularInCategory({
    required String category,
    int limit = 10,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('items')
          .where('category', isEqualTo: category)
          .limit(limit * 3)
          .get();

      final items = querySnapshot.docs
          .map((doc) => ItemModel.fromFirestore(doc).toEntity())
          .where((item) => item.status == ItemStatus.active)
          .toList();

      items.sort((a, b) => b.viewCount.compareTo(a.viewCount));

      return items.take(limit).toList();
    } catch (e) {
      print('Error getting popular in category: $e');
      return [];
    }
  }

  /// Get trending items (recently created with high views)
  Future<List<ItemEntity>> getTrendingItems({
    int limit = 10,
    int daysBack = 7,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysBack));

      final querySnapshot = await _firestore
          .collection('items')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoffDate))
          .orderBy('createdAt', descending: true)
          .limit(limit * 5)
          .get();

      final items = querySnapshot.docs
          .map((doc) => ItemModel.fromFirestore(doc).toEntity())
          .where((item) => item.status == ItemStatus.active)
          .toList();

      // Sort by engagement score (views / days since creation)
      items.sort((a, b) {
        final daysA = DateTime.now().difference(a.createdAt).inDays + 1;
        final daysB = DateTime.now().difference(b.createdAt).inDays + 1;
        final scoreA = a.viewCount / daysA;
        final scoreB = b.viewCount / daysB;
        return scoreB.compareTo(scoreA);
      });

      return items.take(limit).toList();
    } catch (e) {
      print('Error getting trending items: $e');
      return [];
    }
  }

  // ========================================
  // PERSONALIZED RECOMMENDATIONS (Simple Version)
  // ========================================

  /// Get personalized recommendations based on user's favorites
  Future<List<ItemEntity>> getPersonalizedRecommendations({
    required String userId,
    int limit = 20,
  }) async {
    try {
      // Get user's favorite items
      final favoritesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .limit(5)
          .get();

      if (favoritesSnapshot.docs.isEmpty) {
        // If no favorites, return trending items
        return getTrendingItems(limit: limit);
      }

      // Get categories from favorites
      final favoriteCategories = <String>{};
      for (final doc in favoritesSnapshot.docs) {
        final category = doc.data()['category'] as String?;
        if (category != null) {
          favoriteCategories.add(category);
        }
      }

      if (favoriteCategories.isEmpty) {
        return getTrendingItems(limit: limit);
      }

      // Get items from favorite categories
      final recommendations = <ItemEntity>[];
      for (final category in favoriteCategories) {
        final items = await getPopularInCategory(
          category: category,
          limit: limit ~/ favoriteCategories.length,
        );
        recommendations.addAll(items);
      }

      // Remove duplicates and shuffle
      final uniqueItems = <String, ItemEntity>{};
      for (final item in recommendations) {
        uniqueItems[item.id] = item;
      }

      final result = uniqueItems.values.toList();
      result.shuffle();

      return result.take(limit).toList();
    } catch (e) {
      print('Error getting personalized recommendations: $e');
      return getTrendingItems(limit: limit);
    }
  }

  // ========================================
  // HELPER: Track viewed item
  // ========================================

  /// Track that a user viewed an item (for recently viewed)
  Future<void> trackItemView({
    required String userId,
    required String itemId,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'recentlyViewed': FieldValue.arrayUnion([itemId]),
      });

      // Keep only last 50 viewed items
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final recentlyViewed =
          (userDoc.data()?['recentlyViewed'] as List?)?.cast<String>() ?? [];

      if (recentlyViewed.length > 50) {
        await _firestore.collection('users').doc(userId).update({
          'recentlyViewed': recentlyViewed.sublist(recentlyViewed.length - 50),
        });
      }
    } catch (e) {
      print('Error tracking item view: $e');
    }
  }

  Future<List<CategorySummary>> getTopCategories({int limit = 8}) async {
    try {
      final snapshot = await _firestore
          .collection('items')
          .where('status', isEqualTo: 'active')
          .get();

      final counts = <String, int>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final rawCategory = data['category'];
        if (rawCategory is! String) continue;
        final category = rawCategory.trim();
        if (category.isEmpty) continue;
        counts[category] = (counts[category] ?? 0) + 1;
      }

      if (counts.isEmpty) {
        return [];
      }

      final entries = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return entries.take(limit).map((entry) {
        return CategorySummary(category: entry.key, count: entry.value);
      }).toList();
    } catch (e) {
      print('Error getting category summaries: $e');
      return [];
    }
  }
}

class CategorySummary {
  final String category;
  final int count;

  CategorySummary({required this.category, required this.count});
}
