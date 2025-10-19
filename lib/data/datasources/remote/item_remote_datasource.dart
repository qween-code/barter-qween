import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/exceptions.dart';
import '../../models/item_model.dart';

abstract class ItemRemoteDataSource {
  Future<ItemModel> createItem(ItemModel item);
  Future<ItemModel> updateItem(ItemModel item);
  Future<void> deleteItem(String itemId);
  Future<ItemModel> getItem(String itemId);
  Future<List<ItemModel>> getAllItems({
    String? category,
    String? city,
    int? limit,
  });
  Future<List<ItemModel>> getUserItems(String userId);
  Future<List<String>> uploadImages(String itemId, List<File> images);
  Future<void> deleteImage(String imageUrl);
  Future<List<ItemModel>> searchItems(String query);
  Future<void> incrementViewCount(String itemId);
  Future<List<ItemModel>> getFeaturedItems({int limit = 10});
  Future<List<ItemModel>> getRecentItems();
  Future<List<ItemModel>> getTrendingItems();
  Future<List<ItemModel>> getRecommendedItems({
    required String userId,
    String? city,
    double? latitude,
    double? longitude,
    int limit,
  });
  Future<List<String>> getSearchSuggestions(String query);
}

@LazySingleton(as: ItemRemoteDataSource)
class ItemRemoteDataSourceImpl implements ItemRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;

  ItemRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
    required this.auth,
  });

  @override
  Future<ItemModel> createItem(ItemModel item) async {
    try {
      final docRef = await firestore
          .collection('items')
          .add(item.toFirestore());
      final doc = await docRef.get();
      return ItemModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ItemModel> updateItem(ItemModel item) async {
    try {
      await firestore
          .collection('items')
          .doc(item.id)
          .update(item.toFirestore());
      final doc = await firestore.collection('items').doc(item.id).get();
      return ItemModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteItem(String itemId) async {
    try {
      // Get item to delete images
      final doc = await firestore.collection('items').doc(itemId).get();
      if (doc.exists) {
        final item = ItemModel.fromFirestore(doc);

        // Delete all images
        for (final imageUrl in item.images) {
          try {
            await deleteImage(imageUrl);
          } catch (e) {
            // Continue even if image deletion fails
          }
        }
      }

      // Delete item document
      await firestore.collection('items').doc(itemId).delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ItemModel> getItem(String itemId) async {
    try {
      final doc = await firestore.collection('items').doc(itemId).get();
      if (!doc.exists) {
        throw ServerException('Item not found');
      }
      return ItemModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ItemModel>> getAllItems({
    String? category,
    String? city,
    int? limit,
  }) async {
    try {
      Query query = firestore.collection('items');

      query = query.where('status', isEqualTo: 'active');

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }

      query = query.orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        // Log once so we know an index should be created for optimal performance.
        // ignore: avoid_print
        print(
          '[Firestore] Missing composite index for getAllItems query. '
          'Falling back to client-side filtering. Generated URL: ${e.message}',
        );
        // Fallback when a composite index is missing. Fetch a broader result set
        // and filter client-side so the UI can still render content.
        final fallback = await _loadWithoutCompositeIndex(
          category: category,
          city: city,
          limit: limit,
        );
        return fallback;
      }
      throw ServerException(e.message ?? e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ItemModel>> getUserItems(String userId) async {
    try {
      final snapshot = await firestore
          .collection('items')
          .where('ownerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        // ignore: avoid_print
        print(
          '[Firestore] Missing composite index for getUserItems query. '
          'Falling back to client-side ordering. Generated URL: ${e.message}',
        );

        final fallbackSnapshot = await firestore
            .collection('items')
            .where('ownerId', isEqualTo: userId)
            .get();

        final items = fallbackSnapshot.docs
            .map((doc) => ItemModel.fromFirestore(doc))
            .toList();

        items.sort((a, b) {
          final aDate = a.createdAt.toDate();
          final bDate = b.createdAt.toDate();
          return bDate.compareTo(aDate);
        });

        return items;
      }
      throw ServerException(e.message ?? e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<String>> uploadImages(String itemId, List<File> images) async {
    try {
      final List<String> uploadedUrls = [];

      // Get current user ID from Firebase Auth
      final userId = auth.currentUser?.uid;
      if (userId == null) {
        throw ServerException('User not authenticated');
      }

      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        // Use userId in path to match storage rules
        final fileName = 'items/$userId/${itemId}_${timestamp}_$i.jpg';
        final ref = storage.ref().child(fileName);

        await ref.putFile(file);
        final downloadUrl = await ref.getDownloadURL();
        uploadedUrls.add(downloadUrl);
      }

      return uploadedUrls;
    } catch (e) {
      throw ServerException('Failed to upload images: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw ServerException('Failed to delete image: ${e.toString()}');
    }
  }

  @override
  Future<List<ItemModel>> searchItems(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation. For production, consider using Algolia or similar
      final snapshot = await firestore
          .collection('items')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      final allItems = snapshot.docs
          .map((doc) => ItemModel.fromFirestore(doc))
          .toList();

      // Filter items by query
      final searchQuery = query.toLowerCase();
      return allItems.where((item) {
        return item.title.toLowerCase().contains(searchQuery) ||
            item.description.toLowerCase().contains(searchQuery) ||
            item.category.toLowerCase().contains(searchQuery);
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> incrementViewCount(String itemId) async {
    try {
      await firestore.runTransaction((transaction) async {
        final itemRef = firestore.collection('items').doc(itemId);
        final snapshot = await transaction.get(itemRef);
        if (!snapshot.exists) {
          return;
        }

        final current = (snapshot.data()?['viewCount'] as num?) ?? 0;
        transaction.update(itemRef, {
          'viewCount': current + 1,
        });
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ItemModel>> getFeaturedItems({int limit = 10}) async {
    try {
      final snapshot = await firestore
          .collection('items')
          .where('status', isEqualTo: 'active')
          .where('isFeatured', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ItemModel>> getRecentItems() async {
    try {
      final snapshot = await firestore
          .collection('items')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ItemModel>> getTrendingItems() async {
    try {
      final snapshot = await firestore
          .collection('items')
          .where('status', isEqualTo: 'active')
          .orderBy('viewCount', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ItemModel>> getRecommendedItems({
    required String userId,
    String? city,
    double? latitude,
    double? longitude,
    int limit = 20,
  }) async {
    try {
      Query query = firestore.collection('items');
      query = query.where('status', isEqualTo: 'active');

      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit * 2);

      final snapshot = await query.get();
      var items = snapshot.docs
          .map((doc) => ItemModel.fromFirestore(doc))
          .where((item) => item.ownerId != userId)
          .toList();

      if (items.length < limit) {
        final fallback = await getTrendingItems();
        for (final item in fallback) {
          if (item.ownerId != userId &&
              !items.any((existing) => existing.id == item.id)) {
            items.add(item);
          }
          if (items.length >= limit) break;
        }
      }

      if (latitude != null && longitude != null) {
        items.sort((a, b) {
          final distA = (a.latitude != null && a.longitude != null)
              ? _calculateDistance(
                  latitude,
                  longitude,
                  a.latitude!,
                  a.longitude!,
                )
              : double.infinity;
          final distB = (b.latitude != null && b.longitude != null)
              ? _calculateDistance(
                  latitude,
                  longitude,
                  b.latitude!,
                  b.longitude!,
                )
              : double.infinity;
          return distA.compareTo(distB);
        });
      }

      return items.take(limit).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        // ignore: avoid_print
        print(
          '[Firestore] Missing composite index for getRecommendedItems '
          'query. Using client-side fallback. Generated URL: ${e.message}',
        );
        final fallback = await _loadWithoutCompositeIndex(
          category: null,
          city: city,
          limit: limit * 2,
        );

        var items = fallback.where((item) => item.ownerId != userId).toList();

        if (latitude != null && longitude != null) {
          items.sort((a, b) {
            final distA = (a.latitude != null && a.longitude != null)
                ? _calculateDistance(
                    latitude,
                    longitude,
                    a.latitude!,
                    a.longitude!,
                  )
                : double.infinity;
            final distB = (b.latitude != null && b.longitude != null)
                ? _calculateDistance(
                    latitude,
                    longitude,
                    b.latitude!,
                    b.longitude!,
                  )
                : double.infinity;
            return distA.compareTo(distB);
          });
        }

        if (items.length < limit) {
          final trendingFallback = await getTrendingItems();
          for (final item in trendingFallback) {
            if (item.ownerId != userId &&
                !items.any((existing) => existing.id == item.id)) {
              items.add(item);
            }
            if (items.length >= limit) break;
          }
        }

        return items.take(limit).toList();
      }
      throw ServerException(
        'Failed to load recommended items: ${e.message ?? e.toString()}',
      );
    } catch (e) {
      throw ServerException('Failed to load recommended items: $e');
    }
  }

  @override
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final snapshot = await firestore
          .collection('items')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: '${query}z')
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['title'] as String)
          .toSet()
          .toList();
    } catch (e) {
      return [];
    }
  }

  double _calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(endLat - startLat);
    final dLon = _degreesToRadians(endLng - startLng);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(startLat)) *
            cos(_degreesToRadians(endLat)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;

  Future<List<ItemModel>> _loadWithoutCompositeIndex({
    String? category,
    String? city,
    int? limit,
  }) async {
    final fallbackLimit = (limit ?? 40) * 2;
    final snapshot = await firestore
        .collection('items')
        .orderBy('createdAt', descending: true)
        .limit(fallbackLimit)
        .get();

    var items = snapshot.docs
        .map((doc) => ItemModel.fromFirestore(doc))
        .where((item) => item.status.toLowerCase() == 'active')
        .toList();

    if (category != null && category.isNotEmpty) {
      items = items
          .where(
            (item) => item.category.toLowerCase() == category.toLowerCase(),
          )
          .toList();
    }

    if (city != null && city.isNotEmpty) {
      items = items
          .where(
            (item) => (item.city ?? '').toLowerCase() == city.toLowerCase(),
          )
          .toList();
    }

    return items.take(limit ?? items.length).toList();
  }
}
