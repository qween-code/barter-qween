import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 🌟 WORLD-CLASS AUTH STATES
///
/// Features:
/// - Initial state
/// - Loading state
/// - Success state
/// - Failure state
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final User user;

  const AuthSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
