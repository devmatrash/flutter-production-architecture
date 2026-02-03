/// Base exception for all cache operations
abstract class CacheException implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  const CacheException({
    required this.message,
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() =>
      '$runtimeType: $message${cause != null ? ' (caused by: $cause)' : ''}';
}

/// Key not found in cache
class CacheMissException extends CacheException {
  final String key;

  const CacheMissException({
    required this.key,
    String? message,
    super.cause,
    super.stackTrace,
  }) : super(message: message ?? 'Cache miss for key: $key');
}

/// Failed to serialize/deserialize data
class CacheSerializationException extends CacheException {
  final Type type;
  final dynamic value;

  const CacheSerializationException({
    required this.type,
    this.value,
    super.message = 'Failed to serialize/deserialize type',
    super.cause,
    super.stackTrace,
  });
}

/// Storage driver unavailable or failed
class CacheDriverException extends CacheException {
  final String driverName;

  const CacheDriverException({
    required this.driverName,
    super.message = 'Cache driver failure',
    super.cause,
    super.stackTrace,
  });
}

/// Invalid key format
class CacheKeyException extends CacheException {
  final String invalidKey;

  const CacheKeyException({
    required this.invalidKey,
    super.message = 'Invalid cache key',
    super.cause,
    super.stackTrace,
  });
}

/// Data expired (TTL exceeded)
class CacheTTLExpiredException extends CacheException {
  final String key;
  final DateTime expiredAt;

  const CacheTTLExpiredException({
    required this.key,
    required this.expiredAt,
    String? message,
    super.cause,
    super.stackTrace,
  }) : super(message: message ?? 'Cache entry expired for key: $key');
}

/// General cache operation failure
class CacheOperationException extends CacheException {
  final String operation;

  const CacheOperationException({
    required this.operation,
    super.message = 'Cache operation failed',
    super.cause,
    super.stackTrace,
  });
}
