import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/exceptions.dart';
import '../../models/favorite_model.dart';
import '../../models/item_model.dart';

abstract class FavoriteRemoteDataSource {
  Future<FavoriteModel> addFavorite(String userId, String itemId);
  Future<void> removeFavorite(String userId, String itemId);
  Future<List<ItemModel>> getFavoriteItems(String userId);
  Future<bool> isFavorite(String userId, String itemId);
  Future<List<String>> getFavoriteIds(String userId);
}

@LazySingleton(as: FavoriteRemoteDataSource)
class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  final FirebaseFirestore firestore;

  FavoriteRemoteDataSourceImpl(this.firestore);

  @override
  Future<FavoriteModel> addFavorite(String userId, String itemId) async {
    try {
      // Check if already favorited
      final existing = await firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .where('itemId', isEqualTo: itemId)
          .get();

      if (existing.docs.isNotEmpty) {
        return FavoriteModel.fromFirestore(existing.docs.first);
      }

      // Create new favorite and increment item counter atomically
      FavoriteModel? createdFavorite;
      await firestore.runTransaction((transaction) async {
        final favoriteRef = firestore.collection('favorites').doc();
        transaction.set(favoriteRef, {
          'userId': userId,
          'itemId': itemId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        final itemRef = firestore.collection('items').doc(itemId);
        final itemSnapshot = await transaction.get(itemRef);
        if (itemSnapshot.exists) {
          final current = (itemSnapshot.data()?['favoriteCount'] as num?) ?? 0;
          transaction.update(itemRef, {
            'favoriteCount': current + 1,
          });
        }

        createdFavorite = FavoriteModel(
          id: favoriteRef.id,
          userId: userId,
          itemId: itemId,
          createdAt: DateTime.now(),
        );
      });

      return createdFavorite!;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to add favorite');
    } catch (e) {
      throw ServerException('Failed to add favorite: $e');
    }
  }

  @override
  Future<void> removeFavorite(String userId, String itemId) async {
    try {
      await firestore.runTransaction((transaction) async {
        final favoritesQuery = await firestore
            .collection('favorites')
            .where('userId', isEqualTo: userId)
            .where('itemId', isEqualTo: itemId)
            .get();

        if (favoritesQuery.docs.isEmpty) {
          return;
        }

        for (final doc in favoritesQuery.docs) {
          transaction.delete(doc.reference);
        }

        final itemRef = firestore.collection('items').doc(itemId);
        final itemSnapshot = await transaction.get(itemRef);
        if (itemSnapshot.exists) {
          final current = (itemSnapshot.data()?['favoriteCount'] as num?) ?? 0;
          final nextValue = current - favoritesQuery.docs.length;
          transaction.update(itemRef, {
            'favoriteCount': nextValue < 0 ? 0 : nextValue,
          });
        }
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to remove favorite');
    } catch (e) {
      throw ServerException('Failed to remove favorite: $e');
    }
  }

  @override
  Future<List<ItemModel>> getFavoriteItems(String userId) async {
    try {
      // Get favorite item IDs
      Query<Map<String, dynamic>> query = firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId);

      QuerySnapshot<Map<String, dynamic>> favoritesSnapshot;
      try {
        favoritesSnapshot = await query
            .orderBy('createdAt', descending: true)
            .get();
      } on FirebaseException catch (e) {
        if (e.code == 'failed-precondition') {
          // ignore: avoid_print
          print(
            '[Firestore] Missing composite index for favorites query. '
            'Falling back to unordered results. Generated URL: ${e.message}',
          );
          favoritesSnapshot = await query.get();
        } else {
          rethrow;
        }
      }

      if (favoritesSnapshot.docs.isEmpty) {
        return [];
      }

      final itemIds = favoritesSnapshot.docs
          .map((doc) => doc.data()['itemId'] as String)
          .toList();

      final createdAtMap = favoritesSnapshot.docs.fold<Map<String, Timestamp?>>(
        {},
        (acc, doc) {
          acc[doc.data()['itemId'] as String] =
              doc.data()['createdAt'] as Timestamp?;
          return acc;
        },
      );

      // Fetch items in batches (Firestore 'in' query limit is 10)
      final List<ItemModel> allItems = [];
      for (int i = 0; i < itemIds.length; i += 10) {
        final batch = itemIds.skip(i).take(10).toList();
        final itemsSnapshot = await firestore
            .collection('items')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        allItems.addAll(
          itemsSnapshot.docs
              .map((doc) => ItemModel.fromFirestore(doc))
              .toList(),
        );
      }

      allItems.sort((a, b) {
        final aDate =
            createdAtMap[a.id]?.toDate() ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            createdAtMap[b.id]?.toDate() ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      return allItems;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get favorite items');
    } catch (e) {
      throw ServerException('Failed to get favorite items: $e');
    }
  }

  @override
  Future<bool> isFavorite(String userId, String itemId) async {
    try {
      final querySnapshot = await firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .where('itemId', isEqualTo: itemId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to check favorite');
    } catch (e) {
      throw ServerException('Failed to check favorite: $e');
    }
  }

  @override
  Future<List<String>> getFavoriteIds(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['itemId'] as String)
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get favorite IDs');
    } catch (e) {
      throw ServerException('Failed to get favorite IDs: $e');
    }
  }
}
