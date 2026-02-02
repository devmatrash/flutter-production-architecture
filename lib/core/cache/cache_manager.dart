import 'dart:developer';

import 'package:flutter_production_architecture/core/cache/cache_storage.dart';

class CacheManager {
  final CacheStorage _regularStorage;
  final CacheStorage _secureStorage;

  CacheManager({
    required CacheStorage regularStorage,
    required CacheStorage secureStorage,
  }) : _regularStorage = regularStorage,
       _secureStorage = secureStorage;

  // Regular storage methods
  Future<void> set<T>(String key, T value) async {
    await _regularStorage.set<T>(key, value);
    log('Set regular cache: $key', name: 'CacheManager');
  }

  Future<T?> get<T>(String key) async {
    final value = await _regularStorage.get<T>(key);
    return value;
  }

  Future<bool> has(String key) async {
    return await _regularStorage.has(key);
  }

  Future<void> remove(String key) async {
    await _regularStorage.remove(key);
  }

  // Secure storage methods
  Future<void> setSecure<T>(String key, T value) async {
    await _secureStorage.set<T>(key, value);
    log('Set secure cache: $key', name: 'CacheManager');
  }

  Future<T?> getSecure<T>(String key) async {
    return await _secureStorage.get<T>(key);
  }

  Future<bool> hasSecure(String key) async {
    return await _secureStorage.has(key);
  }

  Future<void> removeSecure(String key) async {
    await _secureStorage.remove(key);
  }

  // Utility methods
  Future<void> clear() async {
    await _regularStorage.clear();
  }

  Future<void> clearSecure() async {
    await _secureStorage.clear();
  }

  Future<void> clearAll() async {
    await clear();
    await clearSecure();
  }

  Future<List<String>> getAllKeys() async {
    return await _regularStorage.keys();
  }

  Future<Map<String, int>> getCacheStats() async {
    final regularSize = await _regularStorage.size();
    final secureSize = await _secureStorage.size();

    return {
      'regular': regularSize,
      'secure': secureSize,
      'total': regularSize + secureSize,
    };
  }
}
