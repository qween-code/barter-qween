/// Base Exception class
class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

// Auth Exceptions
class AuthException extends AppException {
  const AuthException(super.message);
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException() : super('Invalid credentials');
}

class UserNotFoundException extends AuthException {
  const UserNotFoundException() : super('User not found');
}

class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException() : super('Email already in use');
}

class WeakPasswordException extends AuthException {
  const WeakPasswordException() : super('Password is too weak');
}

class InvalidOtpException extends AuthException {
  const InvalidOtpException() : super('Invalid OTP');
}

// Network Exceptions
class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Server error']);
}

// Cache Exceptions
class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

// Validation Exceptions
class ValidationException extends AppException {
  const ValidationException(super.message);
}

// Not Found Exceptions
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found']);
}

// Authorization Exceptions
class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized']);
}

// Unknown Exceptions
class UnknownException extends AppException {
  const UnknownException([super.message = 'Unknown error']);
}
