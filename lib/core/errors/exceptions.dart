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
  const NetworkException() : super('Network error');
}

class ServerException extends AppException {
  const ServerException([String message = 'Server error']) : super(message);
}

// Cache Exceptions
class CacheException extends AppException {
  const CacheException() : super('Cache error');
}
