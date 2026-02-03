import 'package:flutter_production_architecture/core/cache/cache_config.dart';

/// Validates cache key format and constraints
class CacheValidator {
  final CacheConfig config;

  const CacheValidator(this.config);

  void validate(String key) {
    if (key.isEmpty) {
      throw ArgumentError('Cache key cannot be empty');
    }
    if (key.length > config.maxKeyLength) {
      throw ArgumentError(
        'Cache key too long: ${key.length} > ${config.maxKeyLength}',
      );
    }
    if (key.contains('\n') || key.contains('\r')) {
      throw ArgumentError('Cache key cannot contain newlines');
    }
    if (key.startsWith('_') || key.endsWith('_ttl')) {
      throw ArgumentError('Cache key uses reserved pattern');
    }
  }
}
