import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/exceptions.dart';
import '../../models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getUserProfile(String userId);
  Future<UserModel> updateProfile(UserModel user);
  Future<String> uploadAvatar(String userId, File imageFile);
  Future<void> deleteAvatar(String userId);
  Future<void> followUser(String currentUserId, String targetUserId);
  Future<void> unfollowUser(String currentUserId, String targetUserId);
  Future<bool> isFollowing(String currentUserId, String targetUserId);
  Future<Map<String, dynamic>> getUserStats(String userId);
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ProfileRemoteDataSourceImpl({required this.firestore, required this.storage});

  List<String> _uniqueList(dynamic source) {
    final result = <String>[];
    if (source is Iterable) {
      for (final value in source.whereType<String>()) {
        if (!result.contains(value)) {
          result.add(value);
        }
      }
    }
    return result;
  }

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
      final fileName =
          'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
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
  Future<void> followUser(String currentUserId, String targetUserId) async {
    if (currentUserId == targetUserId) {
      return;
    }

    try {
      final usersCollection = firestore.collection('users');
      final currentRef = usersCollection.doc(currentUserId);
      final targetRef = usersCollection.doc(targetUserId);

      await firestore.runTransaction((transaction) async {
        final currentSnap = await transaction.get(currentRef);
        final targetSnap = await transaction.get(targetRef);

        if (!currentSnap.exists || !targetSnap.exists) {
          throw ServerException('User not found');
        }

        final currentData = currentSnap.data() ?? <String, dynamic>{};
        final targetData = targetSnap.data() ?? <String, dynamic>{};

        final currentSocial =
            (currentData['social'] as Map<String, dynamic>?) ??
            <String, dynamic>{};
        final targetSocial =
            (targetData['social'] as Map<String, dynamic>?) ??
            <String, dynamic>{};

        final following = _uniqueList(currentSocial['following']);
        final currentFollowers = _uniqueList(currentSocial['followers']);

        if (following.contains(targetUserId)) {
          return;
        }

        final followers = _uniqueList(targetSocial['followers']);

        final updatedFollowing = List<String>.from(following);
        if (!updatedFollowing.contains(targetUserId)) {
          updatedFollowing.add(targetUserId);
        }

        final updatedFollowers = List<String>.from(followers);
        if (!updatedFollowers.contains(currentUserId)) {
          updatedFollowers.add(currentUserId);
        }

        transaction.set(currentRef, {
          'social': {
            'followers': currentFollowers,
            'followersCount': currentFollowers.length,
            'following': updatedFollowing,
            'followingCount': updatedFollowing.length,
          },
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        transaction.set(targetRef, {
          'social': {
            'followers': updatedFollowers,
            'followersCount': updatedFollowers.length,
          },
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to follow user');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to follow user: $e');
    }
  }

  @override
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    if (currentUserId == targetUserId) {
      return;
    }

    try {
      final usersCollection = firestore.collection('users');
      final currentRef = usersCollection.doc(currentUserId);
      final targetRef = usersCollection.doc(targetUserId);

      await firestore.runTransaction((transaction) async {
        final currentSnap = await transaction.get(currentRef);
        final targetSnap = await transaction.get(targetRef);

        if (!currentSnap.exists || !targetSnap.exists) {
          throw ServerException('User not found');
        }

        final currentData = currentSnap.data() ?? <String, dynamic>{};
        final targetData = targetSnap.data() ?? <String, dynamic>{};

        final currentSocial =
            (currentData['social'] as Map<String, dynamic>?) ??
            <String, dynamic>{};
        final targetSocial =
            (targetData['social'] as Map<String, dynamic>?) ??
            <String, dynamic>{};

        final following = _uniqueList(currentSocial['following']);
        final currentFollowers = _uniqueList(currentSocial['followers']);

        if (!following.contains(targetUserId)) {
          return;
        }

        final updatedFollowing = List<String>.from(following)
          ..remove(targetUserId);
        final updatedFollowers = _uniqueList(targetSocial['followers'])
          ..remove(currentUserId);

        transaction.set(currentRef, {
          'social': {
            'followers': currentFollowers,
            'followersCount': currentFollowers.length,
            'following': updatedFollowing,
            'followingCount': updatedFollowing.length,
          },
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        transaction.set(targetRef, {
          'social': {
            'followers': updatedFollowers,
            'followersCount': updatedFollowers.length,
          },
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to unfollow user');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to unfollow user: $e');
    }
  }

  @override
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    if (currentUserId == targetUserId) {
      return false;
    }

    try {
      final doc = await firestore.collection('users').doc(currentUserId).get();
      if (!doc.exists) {
        return false;
      }

      final data = doc.data();
      final social = (data?['social'] as Map<String, dynamic>?) ?? {};
      final following =
          (social['following'] as List?)?.whereType<String>().toList() ??
          const <String>[];

      return following.contains(targetUserId);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to check follow status');
    } catch (e) {
      throw ServerException('Failed to check follow status: $e');
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

      final tradeCount =
          sentTradesSnapshot.docs.length + receivedTradesSnapshot.docs.length;

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
