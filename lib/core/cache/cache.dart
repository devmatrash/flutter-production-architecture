import 'dart:developer';

import 'package:flutter_production_architecture/core/cache/cache_config.dart';
import 'package:flutter_production_architecture/core/cache/cache_drivers.dart';
import 'package:flutter_production_architecture/core/cache/cache_manager.dart';
import 'package:flutter_production_architecture/core/cache/cache_storage.dart';
import 'package:flutter_production_architecture/core/cache/cache_ttl.dart';
import 'package:flutter_production_architecture/core/cache/cache_validator.dart';

/// Production cache with driver pattern and circuit breaker
class Cache {
  static final _manager = CacheManager();
  static late CacheTTL _ttl;
  static late CacheValidator _validator;

  static Future<void> initialize({
    String? defaultDriver,
    CacheConfig? config,
  }) async {
    await _manager.initialize(defaultDriver: defaultDriver, config: config);
    _ttl = CacheTTL(enabled: _manager.config?.enableTTL ?? false);
    _validator = CacheValidator(_manager.config ?? CacheConfig.defaults());
  }

  static Future<void> set<T>(
    String key,
    T value, {
    String? driver,
    Duration? ttl,
  }) async {
    _validator.validate(key);

    final targetDriver = _manager.getDriver(driver);
    final serialized = CacheSerializer.serialize<T>(value);

    try {
      await targetDriver.set(key, serialized);

      if (ttl != null) {
        _ttl.set(key, ttl);
      }
    } catch (e) {
      if (targetDriver.name != 'memory') {
        if (_manager.config?.logFallbacks == true) {
          log('Driver ${targetDriver.name} failed, using memory', name: 'Cache');
        }
        await _manager.drivers[CacheDriverType.memory]!.set(key, serialized);
      } else {
        rethrow;
      }
    }
  }

  static Future<T?> get<T>(String key, {String? driver}) async {
    _validator.validate(key);

    if (_ttl.isExpired(key)) {
      await remove(key, driver: driver);
      return null;
    }

    final targetDriver = _manager.getDriver(driver);

    try {
      final raw = await targetDriver.get(key);
      if (raw == null) return null;

      return CacheSerializer.deserialize<T>(raw);
    } catch (e) {
      log('Get failed for key $key: $e', name: 'Cache');
      return null;
    }
  }

  static Future<bool> has(String key, {String? driver}) async {
    _validator.validate(key);
    if (_ttl.isExpired(key)) return false;

    final targetDriver = _manager.getDriver(driver);
    return await targetDriver.has(key);
  }

  static Future<void> remove(String key, {String? driver}) async {
    _validator.validate(key);

    final targetDriver = _manager.getDriver(driver);
    await targetDriver.remove(key);
    _ttl.remove(key);
  }

  static Future<void> clear({String? driver}) async {
    final targetDriver = _manager.getDriver(driver);
    final driverKeys = await targetDriver.keys();

    _ttl.removeMultiple(driverKeys);
    await targetDriver.clear();
  }

  static Future<List<String>> keys({String? driver}) async {
    final targetDriver = _manager.getDriver(driver);
    return await targetDriver.keys();
  }

  static Future<int> size({String? driver}) async =>
      (await keys(driver: driver)).length;

  static CacheSecureProxy get secure => CacheSecureProxy._();


  static Future<void> setMultiple(
    Map<String, dynamic> items, {
    String? driver,
    Duration? ttl,
  }) async {
    for (final entry in items.entries) {
      await set(entry.key, entry.value, driver: driver, ttl: ttl);
    }
  }

  static Future<Map<String, T?>> getMultiple<T>(
    List<String> keys, {
    String? driver,
  }) async {
    final results = await Future.wait(
      keys.map((key) => get<T>(key, driver: driver)),
    );
    return Map.fromIterables(keys, results);
  }

  static Future<void> removeMultiple(
    List<String> keys, {
    String? driver,
  }) async {
    await Future.wait(keys.map((key) => remove(key, driver: driver)));
  }


  static Future<void> clearAll() async {
    await _manager.clearAllDrivers();
    _ttl.clear();
  }

  static Future<Map<String, dynamic>> getStats() =>
      _manager.getStats((driver) => size(driver: driver));

  static bool get isInitialized => _manager.isInitialized;
  static String? get defaultDriver => _manager.defaultDriver;
  static Map<String, bool> get driverHealth => _manager.driverHealth;
}

/// Proxy for secure storage operations
class CacheSecureProxy {
  CacheSecureProxy._();
  static const _driver = 'secure_storage';

  Future<void> set<T>(String key, T value, {Duration? ttl}) =>
      Cache.set<T>(key, value, driver: _driver, ttl: ttl);

  Future<T?> get<T>(String key) => Cache.get<T>(key, driver: _driver);

  Future<bool> has(String key) => Cache.has(key, driver: _driver);

  Future<void> remove(String key) => Cache.remove(key, driver: _driver);

  Future<void> clear() => Cache.clear(driver: _driver);
}
