import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/exceptions.dart';
import '../../models/item_model.dart';

abstract class ItemRemoteDataSource {
  Future<ItemModel> createItem(ItemModel item);
  Future<ItemModel> updateItem(ItemModel item);
  Future<void> deleteItem(String itemId);
  Future<ItemModel> getItem(String itemId);
  Future<List<ItemModel>> getAllItems({String? category, String? city, int? limit});
  Future<List<ItemModel>> getUserItems(String userId);
  Future<List<String>> uploadImages(String itemId, List<File> images);
  Future<void> deleteImage(String imageUrl);
  Future<List<ItemModel>> searchItems(String query);
  Future<void> incrementViewCount(String itemId);
  Future<List<ItemModel>> getFeaturedItems({int limit = 10});
}

@LazySingleton(as: ItemRemoteDataSource)
class ItemRemoteDataSourceImpl implements ItemRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ItemRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
  });

  @override
  Future<ItemModel> createItem(ItemModel item) async {
    try {
      final docRef = await firestore.collection('items').add(item.toFirestore());
      final doc = await docRef.get();
      return ItemModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ItemModel> updateItem(ItemModel item) async {
    try {
      await firestore.collection('items').doc(item.id).update(item.toFirestore());
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
      Query query = firestore
          .collection('items')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
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
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<String>> uploadImages(String itemId, List<File> images) async {
    try {
      final List<String> uploadedUrls = [];

      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'items/$itemId/image_${timestamp}_$i.jpg';
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

      final allItems = snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
      
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
      await firestore.collection('items').doc(itemId).update({
        'viewCount': FieldValue.increment(1),
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
}
