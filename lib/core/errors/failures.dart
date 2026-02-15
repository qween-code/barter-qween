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
  const NetworkFailure([super.message = 'Network connection failed']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

// Cache Failures
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

// Validation Failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// Not Found Failures
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

// Authorization Failures
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized']);
}

// Unknown Failures
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unknown error']);
}

/// Helper method to map exceptions to failures
Failure mapExceptionToFailure(Exception e) {
  if (e.toString().contains('auth')) {
    return AuthFailure(e.toString());
  } else if (e.toString().contains('network')) {
    return const NetworkFailure();
  } else if (e.toString().contains('not found')) {
    return const NotFoundFailure();
  } else if (e.toString().contains('unauthorized')) {
    return const UnauthorizedFailure();
  } else {
    return ServerFailure(e.toString());
  }
}
