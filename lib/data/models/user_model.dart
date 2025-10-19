import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.phoneNumber,
    super.photoUrl,
    required super.createdAt,
    super.isEmailVerified,
    super.bio,
    super.address,
    super.city,
    super.location,
    super.latitude,
    super.longitude,
    super.updatedAt,
    super.trustScore,
    super.stats,
    super.social,
  });

  /// From Firebase User
  factory UserModel.fromFirebaseUser(firebase_auth.User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      isEmailVerified: user.emailVerified,
      // Profile fields will be loaded from Firestore separately
    );
  }

  /// From Firestore Document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isEmailVerified: data['isEmailVerified'] ?? false,
      bio: data['bio'],
      address: data['address'],
      city: data['city'],
      location: data['location'],
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      trustScore: (data['trustScore'] as num?)?.toDouble(),
      stats: (data['stats'] as Map?)?.cast<String, dynamic>(),
      social: (data['social'] as Map?)?.cast<String, dynamic>(),
    );
  }

  /// To Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isEmailVerified': isEmailVerified,
      'bio': bio,
      'address': address,
      'city': city,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'trustScore': trustScore,
      'stats': stats,
      'social': social,
    };
  }

  /// To Entity
  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      displayName: displayName,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
      createdAt: createdAt,
      isEmailVerified: isEmailVerified,
      bio: bio,
      address: address,
      city: city,
      location: location,
      latitude: latitude,
      longitude: longitude,
      updatedAt: updatedAt,
      trustScore: trustScore,
      stats: stats,
      social: social,
    );
  }
}
