import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getUserProfile(String userId);
  Future<UserModel> updateProfile(UserModel user);
  Future<String> uploadAvatar(String userId, File imageFile);
  Future<void> deleteAvatar(String userId);
  Future<Map<String, dynamic>> getUserStats(String userId);
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ProfileRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
  });

  @override
  Future<UserModel> getUserProfile(String userId) async {
    try {
      print('📖 Fetching profile from Firestore for user: $userId');
      final doc = await firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) {
        print('⚠️ User profile not found in Firestore: $userId');
        throw ServerException('User profile not found in Firestore');
      }
      
      print('✅ Profile found in Firestore');
      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      print('❌ Firebase error getting profile: ${e.message}');
      throw ServerException(e.message ?? 'Failed to get user profile');
    } catch (e) {
      print('❌ Error getting profile: $e');
      throw ServerException('Failed to get user profile: $e');
    }
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    try {
      // Update updatedAt timestamp
      final updatedUser = UserModel(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        phoneNumber: user.phoneNumber,
        photoUrl: user.photoUrl,
        createdAt: user.createdAt,
        isEmailVerified: user.isEmailVerified,
        bio: user.bio,
        address: user.address,
        city: user.city,
        updatedAt: DateTime.now(),
      );

      await firestore
          .collection('users')
          .doc(user.uid)
          .update(updatedUser.toFirestore());

      return updatedUser;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update profile');
    } catch (e) {
      throw ServerException('Failed to update profile: $e');
    }
  }

  @override
  Future<String> uploadAvatar(String userId, File imageFile) async {
    try {
      // Create unique filename
      final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = storage.ref().child('avatars').child(fileName);

      // Upload file
      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': userId},
        ),
      );

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update user photoUrl in Firestore
      await firestore.collection('users').doc(userId).update({
        'photoUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to upload avatar');
    } catch (e) {
      throw ServerException('Failed to upload avatar: $e');
    }
  }

  @override
  Future<void> deleteAvatar(String userId) async {
    try {
      // Get current user to find avatar URL
      final doc = await firestore.collection('users').doc(userId).get();
      final userData = doc.data();
      
      if (userData != null && userData['photoUrl'] != null) {
        final photoUrl = userData['photoUrl'] as String;
        
        // Delete from Storage if it's a Firebase Storage URL
        if (photoUrl.contains('firebasestorage.googleapis.com')) {
          final ref = storage.refFromURL(photoUrl);
          await ref.delete();
        }
      }

      // Remove photoUrl from Firestore
      await firestore.collection('users').doc(userId).update({
        'photoUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete avatar');
    } catch (e) {
      throw ServerException('Failed to delete avatar: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Get item count
      final itemsSnapshot = await firestore
          .collection('items')
          .where('ownerId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .get();
      final itemCount = itemsSnapshot.docs.length;

      // Get trade count (completed trades)
      final sentTradesSnapshot = await firestore
          .collection('tradeOffers')
          .where('fromUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .get();
      
      final receivedTradesSnapshot = await firestore
          .collection('tradeOffers')
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .get();
      
      final tradeCount = sentTradesSnapshot.docs.length + receivedTradesSnapshot.docs.length;

      // Get ratings
      final ratingsSnapshot = await firestore
          .collection('ratings')
          .where('ratedUserId', isEqualTo: userId)
          .get();
      
      double averageRating = 0.0;
      int ratingCount = ratingsSnapshot.docs.length;
      
      if (ratingCount > 0) {
        int totalRating = 0;
        for (final doc in ratingsSnapshot.docs) {
          totalRating += (doc.data()['rating'] as int?) ?? 0;
        }
        averageRating = totalRating / ratingCount;
      }

      return {
        'itemCount': itemCount,
        'tradeCount': tradeCount,
        'averageRating': averageRating,
        'ratingCount': ratingCount,
      };
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get user stats');
    } catch (e) {
      throw ServerException('Failed to get user stats: $e');
    }
  }
}
