import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/exceptions.dart';
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

      // Create new favorite
      final docRef = await firestore.collection('favorites').add({
        'userId': userId,
        'itemId': itemId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final doc = await docRef.get();
      return FavoriteModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to add favorite');
    } catch (e) {
      throw ServerException('Failed to add favorite: $e');
    }
  }

  @override
  Future<void> removeFavorite(String userId, String itemId) async {
    try {
      final querySnapshot = await firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .where('itemId', isEqualTo: itemId)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
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
      final favoritesSnapshot = await firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      if (favoritesSnapshot.docs.isEmpty) {
        return [];
      }

      final itemIds = favoritesSnapshot.docs
          .map((doc) => doc.data()['itemId'] as String)
          .toList();

      // Fetch items in batches (Firestore 'in' query limit is 10)
      final List<ItemModel> allItems = [];
      for (int i = 0; i < itemIds.length; i += 10) {
        final batch = itemIds.skip(i).take(10).toList();
        final itemsSnapshot = await firestore
            .collection('items')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        allItems.addAll(
          itemsSnapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList(),
        );
      }

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
