import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime createdAt;
  final bool isEmailVerified;

  // Profile fields
  final String? bio;
  final String? address;
  final String? city;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime? updatedAt;
  final double? trustScore;
  final Map<String, dynamic>? stats;
  final Map<String, dynamic>? social;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    required this.createdAt,
    this.isEmailVerified = false,
    this.bio,
    this.address,
    this.city,
    this.location,
    this.latitude,
    this.longitude,
    this.updatedAt,
    this.trustScore,
    this.stats,
    this.social,
  });

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    phoneNumber,
    photoUrl,
    createdAt,
    isEmailVerified,
    bio,
    address,
    city,
    location,
    latitude,
    longitude,
    updatedAt,
    trustScore,
    stats,
    social,
  ];

  // CopyWith method for profile updates
  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    DateTime? createdAt,
    bool? isEmailVerified,
    String? bio,
    String? address,
    String? city,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? updatedAt,
    double? trustScore,
    Map<String, dynamic>? stats,
    Map<String, dynamic>? social,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      bio: bio ?? this.bio,
      address: address ?? this.address,
      city: city ?? this.city,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      updatedAt: updatedAt ?? this.updatedAt,
      trustScore: trustScore ?? this.trustScore,
      stats: stats ?? this.stats,
      social: social ?? this.social,
    );
  }
}
