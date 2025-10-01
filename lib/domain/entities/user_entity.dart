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
  final DateTime? updatedAt;

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
    this.updatedAt,
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
        updatedAt,
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
    DateTime? updatedAt,
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
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
