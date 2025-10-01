/// Base exception class for all custom exceptions
class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown when server communication fails
class ServerException extends AppException {
  const ServerException(String message) : super(message);
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  const AuthException(String message) : super(message);
}

/// Exception thrown when cached data is not found
class CacheException extends AppException {
  const CacheException(String message) : super(message);
}

/// Exception thrown when network is not available
class NetworkException extends AppException {
  const NetworkException(String message) : super(message);
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  const ValidationException(String message) : super(message);
}

/// Exception thrown when resource is not found
class NotFoundException extends AppException {
  const NotFoundException(String message) : super(message);
}

/// Exception thrown when user is not authorized
class UnauthorizedException extends AppException {
  const UnauthorizedException(String message) : super(message);
}

/// Exception thrown when an unknown error occurs
class UnknownException extends AppException {
  const UnknownException(String message) : super(message);
}
