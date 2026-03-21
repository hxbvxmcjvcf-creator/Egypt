/// Data-layer exceptions that get mapped to domain Failures.
/// These are NEVER shown directly to users.

class AppException implements Exception {
  final String code;
  final String message;
  final dynamic data;

  const AppException({
    required this.code,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'AppException[$code]: $message';
}

class NetworkException extends AppException {
  const NetworkException({super.message = 'Network error', super.data})
      : super(code: 'NET_001');
}

class TimeoutException extends AppException {
  const TimeoutException({super.message = 'Request timeout', super.data})
      : super(code: 'NET_002');
}

class ServerException extends AppException {
  const ServerException({super.message = 'Server error', super.data})
      : super(code: 'NET_003');
}

class UnauthorisedException extends AppException {
  const UnauthorisedException({super.message = 'Unauthorised', super.data})
      : super(code: 'AUTH_006');
}

class ForbiddenException extends AppException {
  const ForbiddenException({super.message = 'Access denied', super.data})
      : super(code: 'AUTH_016');
}

class NotFoundException extends AppException {
  const NotFoundException({super.message = 'Not found', super.data})
      : super(code: 'AUTH_002');
}

class ConflictException extends AppException {
  const ConflictException({super.message = 'Conflict', super.data})
      : super(code: 'REG_001');
}

class RateLimitException extends AppException {
  final int retryAfterSeconds;
  const RateLimitException({
    super.message = 'Too many requests',
    this.retryAfterSeconds = 60,
    super.data,
  }) : super(code: 'AUTH_010');
}

class CacheException extends AppException {
  const CacheException({super.message = 'Cache error', super.data})
      : super(code: 'ERR_000');
}
