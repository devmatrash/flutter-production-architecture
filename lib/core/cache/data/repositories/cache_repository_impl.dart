import 'dart:developer';

import 'package:flutter_production_architecture/core/cache/domain/entities/cache_config.dart';
import 'package:flutter_production_architecture/core/cache/domain/repositories/i_cache.dart';
import 'package:flutter_production_architecture/core/cache/domain/exceptions/cache_exceptions.dart';
import 'package:flutter_production_architecture/core/cache/data/datasources/cache_drivers.dart';
import 'package:flutter_production_architecture/core/cache/data/datasources/cache_manager.dart';
import 'package:flutter_production_architecture/core/cache/data/datasources/cache_storage.dart';
import 'package:flutter_production_architecture/core/cache/utils/cache_ttl.dart';
import 'package:flutter_production_architecture/core/cache/utils/cache_validator.dart';

/// Injectable cache implementation (testable, mockable)
class CacheImpl implements ICache {
  final CacheManager _manager;
  final CacheTTL _ttl;
  final CacheValidator _validator;

  CacheImpl({
    required CacheManager manager,
    required CacheTTL ttl,
    required CacheValidator validator,
  })  : _manager = manager,
        _ttl = ttl,
        _validator = validator;

  /// Factory constructor for easy initialization
  static Future<CacheImpl> create({
    String? defaultDriver,
    CacheConfig? config,
  }) async {
    final manager = CacheManager();
    final cacheConfig = config ?? CacheConfig.defaults();
    await manager.initialize(defaultDriver: defaultDriver, config: cacheConfig);

    final ttl = CacheTTL(enabled: manager.config?.enableTTL ?? false);
    final validator = CacheValidator(manager.config ?? CacheConfig.defaults());

    return CacheImpl(manager: manager, ttl: ttl, validator: validator);
  }

  @override
  Future<void> set<T>(
    String key,
    T value, {
    String? driver,
    Duration? ttl,
  }) async {
    try {
      _validator.validate(key);
    } on ArgumentError catch (e, stack) {
      throw CacheKeyException(
        invalidKey: key,
        message: e.message,
        cause: e,
        stackTrace: stack,
      );
    }

    final targetDriver = _manager.getDriver(driver);
    final String serialized;

    try {
      serialized = CacheSerializer.serialize<T>(value);
    } catch (e, stack) {
      throw CacheSerializationException(
        type: T,
        value: value,
        message: 'Failed to serialize type $T',
        cause: e,
        stackTrace: stack,
      );
    }

    try {
      await targetDriver.set(key, serialized);

      if (ttl != null) {
        _ttl.set(key, ttl);
      }
    } catch (e, stack) {
      if (targetDriver.name != 'memory') {
        if (_manager.config?.logFallbacks == true) {
          log('Driver ${targetDriver.name} failed, using memory', name: 'Cache');
        }
        try {
          await _manager.drivers[CacheDriverType.memory]!.set(key, serialized);
        } catch (fallbackError, fallbackStack) {
          throw CacheDriverException(
            driverName: 'memory',
            message: 'Fallback to memory driver also failed',
            cause: fallbackError,
            stackTrace: fallbackStack,
          );
        }
      } else {
        throw CacheDriverException(
          driverName: targetDriver.name,
          message: 'Memory driver failed',
          cause: e,
          stackTrace: stack,
        );
      }
    }
  }

  @override
  Future<T?> get<T>(String key, {String? driver}) async {
    try {
      _validator.validate(key);
    } on ArgumentError catch (e, stack) {
      throw CacheKeyException(
        invalidKey: key,
        message: e.message,
        cause: e,
        stackTrace: stack,
      );
    }

    if (_ttl.isExpired(key)) {
      await remove(key, driver: driver);
      throw CacheTTLExpiredException(
        key: key,
        expiredAt: DateTime.now(),
      );
    }

    final targetDriver = _manager.getDriver(driver);

    try {
      final raw = await targetDriver.get(key);
      if (raw == null) {
        throw CacheMissException(key: key);
      }

      try {
        return CacheSerializer.deserialize<T>(raw);
      } catch (e, stack) {
        throw CacheSerializationException(
          type: T,
          message: 'Failed to deserialize type $T',
          cause: e,
          stackTrace: stack,
        );
      }
    } catch (e, stack) {
      if (e is CacheException) rethrow;

      throw CacheOperationException(
        operation: 'get',
        message: 'Failed to get key: $key',
        cause: e,
        stackTrace: stack,
      );
    }
  }

  @override
  Future<bool> has(String key, {String? driver}) async {
    try {
      _validator.validate(key);
    } on ArgumentError {
      return false;
    }

    if (_ttl.isExpired(key)) return false;

    final targetDriver = _manager.getDriver(driver);
    return await targetDriver.has(key);
  }

  @override
  Future<void> remove(String key, {String? driver}) async {
    try {
      _validator.validate(key);
    } on ArgumentError catch (e, stack) {
      throw CacheKeyException(
        invalidKey: key,
        message: e.message,
        cause: e,
        stackTrace: stack,
      );
    }

    final targetDriver = _manager.getDriver(driver);
    await targetDriver.remove(key);
    _ttl.remove(key);
  }

  @override
  Future<void> clear({String? driver}) async {
    final targetDriver = _manager.getDriver(driver);
    final driverKeys = await targetDriver.keys();

    _ttl.removeMultiple(driverKeys);
    await targetDriver.clear();
  }

  @override
  Future<List<String>> keys({String? driver}) async {
    final targetDriver = _manager.getDriver(driver);
    return await targetDriver.keys();
  }

  @override
  Future<int> size({String? driver}) async =>
      (await keys(driver: driver)).length;

  @override
  Future<void> setMultiple(
    Map<String, dynamic> items, {
    String? driver,
    Duration? ttl,
  }) async {
    for (final entry in items.entries) {
      await set(entry.key, entry.value, driver: driver, ttl: ttl);
    }
  }

  @override
  Future<Map<String, T?>> getMultiple<T>(
    List<String> keys, {
    String? driver,
  }) async {
    final results = <String, T?>{};

    for (final key in keys) {
      try {
        results[key] = await get<T>(key, driver: driver);
      } on CacheMissException {
        results[key] = null;
      } on CacheTTLExpiredException {
        results[key] = null;
      }
    }

    return results;
  }

  @override
  Future<void> removeMultiple(
    List<String> keys, {
    String? driver,
  }) async {
    await Future.wait(keys.map((key) => remove(key, driver: driver)));
  }

  @override
  Future<void> clearAll() async {
    await _manager.clearAllDrivers();
    _ttl.clear();
  }

  @override
  Future<Map<String, dynamic>> getStats() =>
      _manager.getStats((driver) => size(driver: driver));

  @override
  bool get isInitialized => _manager.isInitialized;

  @override
  String? get defaultDriver => _manager.defaultDriver;

  @override
  Map<String, bool> get driverHealth => _manager.driverHealth;
}

/// Secure cache implementation
class SecureCacheImpl implements ISecureCache {
  final ICache _cache;
  static const _driver = 'secure_storage';

  SecureCacheImpl(this._cache);

  @override
  Future<void> set<T>(String key, T value, {Duration? ttl}) =>
      _cache.set<T>(key, value, driver: _driver, ttl: ttl);

  @override
  Future<T?> get<T>(String key) async {
    try {
      return await _cache.get<T>(key, driver: _driver);
    } on CacheMissException {
      return null;
    } on CacheTTLExpiredException {
      return null;
    }
  }

  @override
  Future<bool> has(String key) => _cache.has(key, driver: _driver);

  @override
  Future<void> remove(String key) => _cache.remove(key, driver: _driver);

  @override
  Future<void> clear() => _cache.clear(driver: _driver);
}
