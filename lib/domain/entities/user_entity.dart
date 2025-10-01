import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime createdAt;
  final bool isEmailVerified;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    required this.createdAt,
    this.isEmailVerified = false,
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
      ];
}
