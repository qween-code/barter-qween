import 'package:equatable/equatable.dart';

/// Base Failure class
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

// Auth Failures
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super('Invalid email or password');
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure() : super('User not found');
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure() : super('Email already in use');
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure() : super('Password is too weak');
}

class InvalidOtpFailure extends AuthFailure {
  const InvalidOtpFailure() : super('Invalid OTP code');
}

// Network Failures
class NetworkFailure extends Failure {
  const NetworkFailure() : super('Network connection failed');
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

// Cache Failures
class CacheFailure extends Failure {
  const CacheFailure() : super('Cache error occurred');
}

// Validation Failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
