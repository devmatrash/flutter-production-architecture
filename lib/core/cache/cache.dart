import 'dart:developer';

import 'package:flutter_production_architecture/core/cache/cache_storage.dart';

/*
 * Cache - Static global cache interface with intelligent defaults
 *
 * Provides clean, intuitive API:
 * - Cache.set<T>() / Cache.get<T>() for regular (non-sensitive) data
 * - Cache.secure.set<T>() / Cache.secure.get<T>() for sensitive data only
 *
 * Usage:
 * ```dart
 * // Default to regular storage - no .regular needed!
 * await Cache.set<String>('username', 'john_doe');
 * await Cache.set<User>('current_user', user);
 * final username = await Cache.get<String>('username');
 *
 * // Only use .secure when you need encryption
 * await Cache.secure.set<String>('token', 'jwt_here');
 * final token = await Cache.secure.get<String>('token');
 * ```
 */
class Cache {
  static CacheStorage? _regularStorage;
  static CacheStorage? _secureStorage;

  // Initialize cache storages (called during app bootstrap)
  static void initialize({
    required CacheStorage regularStorage,
    required CacheStorage secureStorage,
  }) {
    _regularStorage = regularStorage;
    _secureStorage = secureStorage;
    log('Cache initialized with regular and secure storage', name: 'Cache');
  }

  // ==================== DEFAULT REGULAR STORAGE METHODS ====================

  /// Store a value in regular (non-secure) cache - DEFAULT behavior
  static Future<void> set<T>(String key, T value) async {
    if (_regularStorage == null) {
      throw StateError(
        'Cache not initialized. This usually happens when:\n'
        '1. SharedPreferences failed to initialize (check Flutter binding)\n'
        '2. Cache initialization was called too early in app lifecycle\n'
        '3. Platform plugins are not properly set up\n'
        'Check the AppBootstrap logs for cache initialization errors.',
      );
    }
    await _regularStorage!.set<T>(key, value);
    log('Regular cache set: $key (${T.toString()})', name: 'Cache');
  }

  /// Retrieve a value from regular cache - DEFAULT behavior
  static Future<T?> get<T>(String key) async {
    if (_regularStorage == null) {
      throw StateError(
        'Cache not initialized. Check AppBootstrap logs for initialization errors.',
      );
    }
    final value = await _regularStorage!.get<T>(key);
    log(
      'Regular cache get: $key (${value != null ? 'found' : 'not found'})',
      name: 'Cache',
    );
    return value;
  }

  /// Check if key exists in regular cache
  static Future<bool> has(String key) async {
    if (_regularStorage == null) {
      throw StateError(
        'Cache not initialized. Check AppBootstrap logs for initialization errors.',
      );
    }
    return await _regularStorage!.has(key);
  }

  /// Remove a key from regular cache
  static Future<void> remove(String key) async {
    if (_regularStorage == null) {
      throw StateError(
        'Cache not initialized. Check AppBootstrap logs for initialization errors.',
      );
    }
    await _regularStorage!.remove(key);
    log('Regular cache removed: $key', name: 'Cache');
  }

  /// Clear all regular cache
  static Future<void> clear() async {
    if (_regularStorage == null) {
      throw StateError(
        'Cache not initialized. Check AppBootstrap logs for initialization errors.',
      );
    }
    await _regularStorage!.clear();
    log('Regular cache cleared', name: 'Cache');
  }

  /// Get all keys from regular cache
  static Future<List<String>> keys() async {
    if (_regularStorage == null) {
      throw StateError(
        'Cache not initialized. Check AppBootstrap logs for initialization errors.',
      );
    }
    return await _regularStorage!.keys();
  }

  /// Get regular cache size
  static Future<int> size() async {
    if (_regularStorage == null) {
      throw StateError(
        'Cache not initialized. Check AppBootstrap logs for initialization errors.',
      );
    }
    return await _regularStorage!.size();
  }

  // ==================== SECURE STORAGE ACCESS ====================

  /// Access to secure cache - only when you need encryption
  static CacheProxy get secure {
    if (_secureStorage == null) {
      throw StateError(
        'Cache not initialized. Check AppBootstrap logs for initialization errors.',
      );
    }
    return CacheProxy._(_secureStorage!, 'Secure');
  }

  // ==================== UTILITY METHODS ====================

  /// Clear both regular and secure cache
  static Future<void> clearAll() async {
    await clear();
    await secure.clear();
    log('All cache cleared (regular + secure)', name: 'Cache');
  }

  /// Get statistics for both storages
  static Future<Map<String, int>> getStats() async {
    final regularSize = await size();
    final secureSize = await secure.size();

    return {
      'regular': regularSize,
      'secure': secureSize,
      'total': regularSize + secureSize,
    };
  }

  // ==================== BATCH OPERATIONS FOR REGULAR CACHE ====================

  /// Store multiple items in regular cache
  static Future<void> setMultiple(Map<String, dynamic> items) async {
    await Future.wait(items.entries.map((e) => set(e.key, e.value)));
  }

  /// Retrieve multiple items from regular cache
  static Future<Map<String, T?>> getMultiple<T>(List<String> keys) async {
    final results = await Future.wait(keys.map((key) => get<T>(key)));
    return Map.fromIterables(keys, results);
  }

  /// Remove multiple keys from regular cache
  static Future<void> removeMultiple(List<String> keys) async {
    await Future.wait(keys.map(remove));
  }

  /// Check if cache is initialized
  static bool get isInitialized =>
      _regularStorage != null && _secureStorage != null;
}

/*
 * CacheProxy - Wrapper that provides clean method names
 *
 * Eliminates the need for setSecure/getSecure by using properties.
 * Each proxy instance represents either regular or secure storage.
 */
class CacheProxy {
  final CacheStorage _storage;
  final String _type;

  CacheProxy._(this._storage, this._type);

  /// Store a value with type safety
  Future<void> set<T>(String key, T value) async {
    await _storage.set<T>(key, value);
    log('$_type cache set: $key (${T.toString()})', name: 'Cache');
  }

  /// Retrieve a value with type safety
  Future<T?> get<T>(String key) async {
    final value = await _storage.get<T>(key);
    log(
      '$_type cache get: $key (${value != null ? 'found' : 'not found'})',
      name: 'Cache',
    );
    return value;
  }

  /// Check if key exists
  Future<bool> has(String key) async {
    return await _storage.has(key);
  }

  /// Remove a key
  Future<void> remove(String key) async {
    await _storage.remove(key);
    log('$_type cache removed: $key', name: 'Cache');
  }

  /// Clear all data in this storage
  Future<void> clear() async {
    await _storage.clear();
    log('$_type cache cleared', name: 'Cache');
  }

  /// Get all keys
  Future<List<String>> keys() async {
    return await _storage.keys();
  }

  /// Get storage size
  Future<int> size() async {
    return await _storage.size();
  }

  /// Batch operations
  Future<void> setMultiple(Map<String, dynamic> items) async {
    await Future.wait(items.entries.map((e) => set(e.key, e.value)));
  }

  Future<Map<String, T?>> getMultiple<T>(List<String> keys) async {
    final results = await Future.wait(keys.map((key) => get<T>(key)));

    return Map.fromIterables(keys, results);
  }

  Future<void> removeMultiple(List<String> keys) async {
    await Future.wait(keys.map(remove));
  }
}
