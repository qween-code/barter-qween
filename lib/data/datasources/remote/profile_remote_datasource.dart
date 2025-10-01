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
      final doc = await firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) {
        throw ServerException('User not found');
      }
      
      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get user profile');
    } catch (e) {
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
}
