import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

/// Gelişmiş veri çekme servisi
@injectable
class DataService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DataService(this._firestore, this._auth);

  /// Kullanıcı verilerini çek
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  /// Ürünleri çek (sayfalama ile)
  Future<List<Map<String, dynamic>>> getItems({
    int limit = 20,
    DocumentSnapshot? lastDocument,
    String? category,
    String? searchQuery,
  }) async {
    try {
      Query query = _firestore.collection('items');

      // Filtreleme
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.where('title', isGreaterThanOrEqualTo: searchQuery)
                    .where('title', isLessThan: searchQuery + '\uf8ff');
      }

      // Sıralama ve limit
      query = query.orderBy('createdAt', descending: true).limit(limit);

      // Sayfalama
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching items: $e');
      return [];
    }
  }

  /// Kullanıcının ürünlerini çek
  Future<List<Map<String, dynamic>>> getUserItems(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('items')
          .where('ownerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching user items: $e');
      return [];
    }
  }

  /// Favori ürünleri çek
  Future<List<Map<String, dynamic>>> getFavoriteItems(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) return [];

      final itemIds = snapshot.docs.map((doc) => doc.data()['itemId'] as String).toList();
      
      final itemsSnapshot = await _firestore
          .collection('items')
          .where(FieldPath.documentId, whereIn: itemIds)
          .get();

      return itemsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching favorite items: $e');
      return [];
    }
  }

  /// Kategorileri çek
  Future<List<String>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => doc.data()['name'] as String).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      return ['Elektronik', 'Giyim', 'Ev & Yaşam', 'Spor', 'Kitap', 'Diğer'];
    }
  }

  /// Gerçek zamanlı dinleyici
  Stream<List<Map<String, dynamic>>> listenToItems({
    String? category,
    int limit = 20,
  }) {
    Query query = _firestore.collection('items');

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    query = query.orderBy('createdAt', descending: true).limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Cache temizleme
  Future<void> clearCache() async {
    // Firestore cache'i temizle
    await _firestore.clearPersistence();
  }
}
