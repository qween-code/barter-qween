import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Failure when server communication fails
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

/// Failure when authentication fails
class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

/// Failure when cached data is not available
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

/// Failure when network is not available
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

/// Failure when validation fails
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

/// Failure when resource is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure(String message) : super(message);
}

/// Failure when user is not authorized
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(String message) : super(message);
}

/// Failure when an unknown error occurs
class UnknownFailure extends Failure {
  const UnknownFailure(String message) : super(message);
}

/// Helper method to map exceptions to failures
Failure mapExceptionToFailure(Exception e) {
  if (e.toString().contains('auth')) {
    return AuthFailure(e.toString());
  } else if (e.toString().contains('network')) {
    return NetworkFailure(e.toString());
  } else if (e.toString().contains('not found')) {
    return NotFoundFailure(e.toString());
  } else if (e.toString().contains('unauthorized')) {
    return UnauthorizedFailure(e.toString());
  } else {
    return ServerFailure(e.toString());
  }
}
