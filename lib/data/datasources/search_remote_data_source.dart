import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/entities/search/search_filter_entity.dart';
import '../models/item_model.dart';

/// Remote data source for search operations using Firestore
@injectable
class SearchRemoteDataSource {
  final FirebaseFirestore firestore;

  SearchRemoteDataSource(this.firestore);

  /// Search items with filters using Firestore queries
  Stream<List<ItemModel>> searchItems({
    required String query,
    required SearchFilterEntity filters,
  }) {
    Query<Map<String, dynamic>> firestoreQuery = firestore.collection('items');

    // Filter by status (default: active only)
    if (filters.statuses != null && filters.statuses!.isNotEmpty) {
      final statusStrings =
          filters.statuses!.map((s) => s.toString().split('.').last).toList();
      firestoreQuery = firestoreQuery.where('status', whereIn: statusStrings);
    } else {
      firestoreQuery = firestoreQuery.where('status',
          isEqualTo: ItemStatus.active.toString().split('.').last);
    }

    // Text search using title (Firestore doesn't support full-text search)
    // For production, consider using Algolia or similar service
    if (query.isNotEmpty) {
      // Use array-contains-any for tags if query matches
      firestoreQuery = firestoreQuery.where('tags', arrayContainsAny: [
        query.toLowerCase(),
      ]);
    }

    // Filter by categories
    if (filters.categories != null && filters.categories!.isNotEmpty) {
      firestoreQuery =
          firestoreQuery.where('category', whereIn: filters.categories);
    }

    // Filter by subcategories
    if (filters.subcategories != null && filters.subcategories!.isNotEmpty) {
      firestoreQuery =
          firestoreQuery.where('subcategory', whereIn: filters.subcategories);
    }

    // Filter by conditions
    if (filters.conditions != null && filters.conditions!.isNotEmpty) {
      firestoreQuery =
          firestoreQuery.where('condition', whereIn: filters.conditions);
    }

    // Filter by colors
    if (filters.colors != null && filters.colors!.isNotEmpty) {
      firestoreQuery = firestoreQuery.where('color', whereIn: filters.colors);
    }

    // Filter by cities
    if (filters.cities != null && filters.cities!.isNotEmpty) {
      firestoreQuery = firestoreQuery.where('city', whereIn: filters.cities);
    }

    // Filter by price range
    if (filters.minPrice != null) {
      firestoreQuery =
          firestoreQuery.where('price', isGreaterThanOrEqualTo: filters.minPrice);
    }
    if (filters.maxPrice != null) {
      firestoreQuery =
          firestoreQuery.where('price', isLessThanOrEqualTo: filters.maxPrice);
    }

    // Filter by date range
    if (filters.startDate != null) {
      firestoreQuery = firestoreQuery.where('createdAt',
          isGreaterThanOrEqualTo: filters.startDate);
    }
    if (filters.endDate != null) {
      firestoreQuery = firestoreQuery.where('createdAt',
          isLessThanOrEqualTo: filters.endDate);
    }

    // Apply sorting
    final sortField = filters.sortBy.firestoreField;
    final isDescending =
        filters.sortDirection == SortDirection.descending;
    firestoreQuery =
        firestoreQuery.orderBy(sortField, descending: isDescending);

    // Apply pagination
    if (filters.startAfter != null) {
      firestoreQuery = firestoreQuery.startAfterDocument(filters.startAfter!);
    }
    firestoreQuery = firestoreQuery.limit(filters.limit);

    // Execute query and convert to ItemModel
    return firestoreQuery.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ItemModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
      }).toList();
    });
  }

  /// Get popular search terms from analytics collection
  Future<List<String>> getPopularSearches({
    String? category,
    int limit = 10,
  }) async {
    Query<Map<String, dynamic>> query =
        firestore.collection('searchAnalytics');

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    query = query.orderBy('searchCount', descending: true).limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => doc.data()['query'] as String)
        .toList();
  }

  /// Track search for analytics
  Future<void> trackSearch({
    required String query,
    required int resultCount,
    required Duration searchDuration,
  }) async {
    final analytics = firestore.collection('searchAnalytics').doc(query);
    
    await analytics.set({
      'query': query,
      'searchCount': FieldValue.increment(1),
      'lastSearched': FieldValue.serverTimestamp(),
      'averageResultCount': resultCount,
      'averageDuration': searchDuration.inMilliseconds,
    }, SetOptions(merge: true));
  }
}
