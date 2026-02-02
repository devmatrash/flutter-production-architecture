import 'dart:developer';

import 'package:flutter_production_architecture/core/cache/cache_storage.dart';

/*
 * InMemoryCache - Fallback cache implementation
 *
 * This is used when SharedPreferences fails to initialize (e.g., iOS simulator bug).
 * Stores data in memory only - data will be lost when app restarts.
 *
 * This is a temporary fallback to ensure the app continues working
 * even when platform-specific storage fails.
 */
class InMemoryCache implements CacheStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> set<T>(String key, T value) async {
    final serialized = CacheSerializer.serialize<T>(value);
    _storage[key] = serialized;
    log('InMemory cache set: $key', name: 'InMemoryCache');
  }

  @override
  Future<T?> get<T>(String key) async {
    final raw = _storage[key];
    if (raw == null) return null;

    try {
      return CacheSerializer.deserialize<T>(raw);
    } catch (e) {
      log(
        'InMemory cache deserialization error for key $key: $e',
        name: 'InMemoryCache',
      );
      return null;
    }
  }

  @override
  Future<bool> has(String key) async {
    return _storage.containsKey(key);
  }

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
    log('InMemory cache removed: $key', name: 'InMemoryCache');
  }

  @override
  Future<void> clear() async {
    _storage.clear();
    log('InMemory cache cleared', name: 'InMemoryCache');
  }

  @override
  Future<List<String>> keys() async {
    return _storage.keys.toList();
  }

  @override
  Future<int> size() async {
    return _storage.length;
  }
}
