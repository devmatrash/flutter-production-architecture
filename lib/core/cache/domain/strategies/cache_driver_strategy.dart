import 'package:flutter_production_architecture/core/cache/data/datasources/cache_drivers.dart';

/// Strategy pattern for selecting cache driver
/// Eliminates magic strings and enables swappable implementations
abstract class CacheDriverStrategy {
  CacheDriverType get driverType;
}

/// Strategy for in-memory cache (non-persistent)
class MemoryDriverStrategy implements CacheDriverStrategy {
  @override
  CacheDriverType get driverType => CacheDriverType.memory;
}

/// Strategy for SharedPreferences persistent storage
class SharedPrefsDriverStrategy implements CacheDriverStrategy {
  @override
  CacheDriverType get driverType => CacheDriverType.sharedPrefs;
}

/// Strategy for secure encrypted storage
class SecureStorageDriverStrategy implements CacheDriverStrategy {
  @override
  CacheDriverType get driverType => CacheDriverType.secureStorage;
}
