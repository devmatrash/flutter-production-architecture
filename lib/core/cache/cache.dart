import 'package:flutter_production_architecture/core/cache/cache_config.dart';
import 'package:flutter_production_architecture/core/cache/cache_impl.dart';
import 'package:flutter_production_architecture/core/cache/interfaces/i_cache.dart';

/// Production cache with driver pattern and circuit breaker
///
/// This is a static facade that delegates to an injectable CacheImpl instance.
/// For testing, inject ICache directly into your classes instead of using this static API.
class Cache {
  static ICache? _instance;
  static ISecureCache? _secureInstance;

  /// Get the cache instance (throws if not initialized)
  static ICache get instance {
    if (_instance == null) {
      throw StateError(
        'Cache not initialized. Call Cache.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Initialize cache with configuration
  static Future<void> initialize({
    String? defaultDriver,
    CacheConfig? config,
  }) async {
    _instance = await CacheImpl.create(
      defaultDriver: defaultDriver,
      config: config,
    );
    _secureInstance = SecureCacheImpl(_instance!);
  }

  static Future<void> set<T>(
    String key,
    T value, {
    String? driver,
    Duration? ttl,
  }) =>
      instance.set<T>(key, value, driver: driver, ttl: ttl);

  static Future<T?> get<T>(String key, {String? driver}) =>
      instance.get<T>(key, driver: driver);

  static Future<bool> has(String key, {String? driver}) =>
      instance.has(key, driver: driver);

  static Future<void> remove(String key, {String? driver}) =>
      instance.remove(key, driver: driver);

  static Future<void> clear({String? driver}) => instance.clear(driver: driver);

  static Future<List<String>> keys({String? driver}) =>
      instance.keys(driver: driver);

  static Future<int> size({String? driver}) => instance.size(driver: driver);

  static CacheSecureProxy get secure => CacheSecureProxy._();

  static Future<void> setMultiple(
    Map<String, dynamic> items, {
    String? driver,
    Duration? ttl,
  }) =>
      instance.setMultiple(items, driver: driver, ttl: ttl);

  static Future<Map<String, T?>> getMultiple<T>(
    List<String> keys, {
    String? driver,
  }) =>
      instance.getMultiple<T>(keys, driver: driver);

  static Future<void> removeMultiple(
    List<String> keys, {
    String? driver,
  }) =>
      instance.removeMultiple(keys, driver: driver);

  static Future<void> clearAll() => instance.clearAll();

  static Future<Map<String, dynamic>> getStats() => instance.getStats();

  static bool get isInitialized => _instance?.isInitialized ?? false;
  static String? get defaultDriver => instance.defaultDriver;
  static Map<String, bool> get driverHealth => instance.driverHealth;
}

/// Proxy for secure storage operations
class CacheSecureProxy {
  CacheSecureProxy._();

  ISecureCache get _secure {
    if (Cache._secureInstance == null) {
      throw StateError(
        'Cache not initialized. Call Cache.initialize() first.',
      );
    }
    return Cache._secureInstance!;
  }

  Future<void> set<T>(String key, T value, {Duration? ttl}) =>
      _secure.set<T>(key, value, ttl: ttl);

  Future<T?> get<T>(String key) => _secure.get<T>(key);

  Future<bool> has(String key) => _secure.has(key);

  Future<void> remove(String key) => _secure.remove(key);

  Future<void> clear() => _secure.clear();
}
