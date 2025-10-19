import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  final Map<String, dynamic>? profileData;
  final Map<String, dynamic>? stats;
  final Map<String, dynamic>? social;

  const AuthAuthenticated(
    this.user, {
    this.profileData,
    this.stats,
    this.social,
  });

  @override
  List<Object?> get props => [user, profileData, stats, social];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
