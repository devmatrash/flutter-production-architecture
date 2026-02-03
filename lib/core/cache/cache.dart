import 'dart:developer';

import 'package:flutter_production_architecture/core/cache/cache_config.dart';
import 'package:flutter_production_architecture/core/cache/cache_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
 * Cache - Enhanced production cache with driver-based architecture
 *
 * Features:
 * - Optional defaultDriver parameter (shared_prefs default)
 * - Circuit breaker pattern with automatic fallback to memory
 * - Optional TTL support (explicit opt-in)
 * - Clean API: Cache.set() uses default, Cache.set(driver: 'memory') overrides
 *
 * Usage:
 * ```dart
 * // Initialize with default driver
 * await Cache.initialize(defaultDriver: 'shared_prefs');
 *
 * // Use default driver (95% of cases)
 * await Cache.set<String>('username', 'john_doe');
 * await Cache.secure.set<String>('token', 'jwt_here');
 *
 * // Override driver when needed (5% of cases)
 * await Cache.set('temp_data', data, driver: 'memory');
 * await Cache.set('session', data, ttl: Duration(hours: 2));
 * ```
 */
class Cache {
  static String? _defaultDriver;
  static CacheConfig? _config;
  static final Map<String, dynamic> _memoryCache = {};
  static final Map<String, DateTime> _memoryTTL = {};
  static SharedPreferences? _sharedPrefs;
  static FlutterSecureStorage? _secureStorage;
  static final Map<String, bool> _driverHealth = {};

  /// Initialize cache with optional default driver and configuration
  static Future<void> initialize({
    String? defaultDriver,
    CacheConfig? config,
  }) async {
    _config = config ?? CacheConfig.defaults();

    // Initialize available drivers
    await _initializeDrivers();

    // Set default driver (with fallback chain)
    if (defaultDriver != null && _driverHealth[defaultDriver] == true) {
      _defaultDriver = defaultDriver;
      log(
        'Cache initialized with default driver: $defaultDriver',
        name: 'Cache',
      );
    } else {
      _defaultDriver = await _detectBestDriver();
      log(
        'Cache initialized with auto-detected driver: $_defaultDriver',
        name: 'Cache',
      );
    }

    log('Cache configuration: $_config', name: 'Cache');
  }

  /// Initialize and test all available drivers
  static Future<void> _initializeDrivers() async {
    // Test SharedPreferences
    try {
      _sharedPrefs = await SharedPreferences.getInstance();
      _driverHealth['shared_prefs'] = true;
      log('SharedPreferences driver available', name: 'Cache');
    } catch (e) {
      _driverHealth['shared_prefs'] = false;
      if (_config?.logFallbacks == true) {
        log('SharedPreferences driver failed: $e', name: 'Cache');
      }
    }

    // Test FlutterSecureStorage
    try {
      _secureStorage = const FlutterSecureStorage(
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );
      _driverHealth['secure_storage'] = true;
      log('FlutterSecureStorage driver available', name: 'Cache');
    } catch (e) {
      _driverHealth['secure_storage'] = false;
      if (_config?.logFallbacks == true) {
        log('FlutterSecureStorage driver failed: $e', name: 'Cache');
      }
    }

    // Memory driver is always available
    _driverHealth['memory'] = true;
    log('Memory driver available', name: 'Cache');
  }

  /// Detect the best available driver based on health checks
  static Future<String> _detectBestDriver() async {
    if (_driverHealth['shared_prefs'] == true) return 'shared_prefs';
    return 'memory'; // Always available fallback
  }

  // ==================== CORE CACHE OPERATIONS ====================

  /// Store a value with optional driver override and TTL
  static Future<void> set<T>(
    String key,
    T value, {
    String? driver,
    Duration? ttl,
  }) async {
    _validateKey(key); // Validate key before processing
    final targetDriver = driver ?? _defaultDriver ?? 'memory';

    // Check TTL configuration
    if (ttl != null && _config?.enableTTL != true) {
      log('WARNING: TTL ignored - not enabled in configuration', name: 'Cache');
    }

    await _setWithDriver<T>(targetDriver, key, value, ttl: ttl);
  }

  /// Retrieve a value with optional driver override
  static Future<T?> get<T>(String key, {String? driver}) async {
    _validateKey(key); // Validate key before processing
    final targetDriver = driver ?? _defaultDriver ?? 'memory';
    return await _getWithDriver<T>(targetDriver, key);
  }

  /// Check if key exists with optional driver override
  static Future<bool> has(String key, {String? driver}) async {
    _validateKey(key); // Validate key before processing
    final targetDriver = driver ?? _defaultDriver ?? 'memory';
    return await _hasWithDriver(targetDriver, key);
  }

  /// Remove a key with optional driver override
  static Future<void> remove(String key, {String? driver}) async {
    _validateKey(key); // Validate key before processing
    final targetDriver = driver ?? _defaultDriver ?? 'memory';
    await _removeWithDriver(targetDriver, key);
  }

  /// Clear cache for specific driver or default driver
  static Future<void> clear({String? driver}) async {
    final targetDriver = driver ?? _defaultDriver ?? 'memory';
    await _clearWithDriver(targetDriver);
  }

  /// Get all keys from specific driver or default driver
  static Future<List<String>> keys({String? driver}) async {
    final targetDriver = driver ?? _defaultDriver ?? 'memory';
    return await _keysWithDriver(targetDriver);
  }

  /// Get cache size for specific driver or default driver
  static Future<int> size({String? driver}) async {
    final targetDriver = driver ?? _defaultDriver ?? 'memory';
    return await _sizeWithDriver(targetDriver);
  }

  // ==================== SECURE CACHE ACCESS ====================

  /// Access secure cache operations
  static CacheSecureProxy get secure => CacheSecureProxy._();

  // ==================== BATCH OPERATIONS ====================

  /// Set multiple items efficiently (if batching enabled)
  static Future<void> setMultiple(
    Map<String, dynamic> items, {
    String? driver,
    Duration? ttl,
  }) async {
    if (_config?.enableBatching == true) {
      await Future.wait(
        items.entries.map(
          (entry) => set(entry.key, entry.value, driver: driver, ttl: ttl),
        ),
      );
    } else {
      for (final entry in items.entries) {
        await set(entry.key, entry.value, driver: driver, ttl: ttl);
      }
    }
  }

  /// Get multiple items efficiently
  static Future<Map<String, T?>> getMultiple<T>(
    List<String> keys, {
    String? driver,
  }) async {
    final results = await Future.wait(
      keys.map((key) => get<T>(key, driver: driver)),
    );
    return Map.fromIterables(keys, results);
  }

  /// Remove multiple keys efficiently
  static Future<void> removeMultiple(
    List<String> keys, {
    String? driver,
  }) async {
    await Future.wait(keys.map((key) => remove(key, driver: driver)));
  }

  // ==================== UTILITY METHODS ====================

  /// Clear all drivers
  static Future<void> clearAll() async {
    await Future.wait([clear(driver: 'memory'), clear(driver: 'shared_prefs')]);
  }

  /// Get cache statistics
  static Future<Map<String, dynamic>> getStats() async {
    final memorySize = await size(driver: 'memory');
    final sharedPrefsSize = _driverHealth['shared_prefs'] == true
        ? await size(driver: 'shared_prefs')
        : 0;

    return {
      'defaultDriver': _defaultDriver,
      'driverHealth': Map<String, bool>.from(_driverHealth),
      'memoryCacheSize': memorySize,
      'sharedPrefsCacheSize': sharedPrefsSize,
      'totalSize': memorySize + sharedPrefsSize,
      'config': _config.toString(),
    };
  }

  /// Check if cache is properly initialized
  static bool get isInitialized => _defaultDriver != null;

  /// Get current default driver
  static String? get defaultDriver => _defaultDriver;

  /// Get driver health status
  static Map<String, bool> get driverHealth =>
      Map<String, bool>.from(_driverHealth);

  // ==================== INTERNAL DRIVER METHODS ====================

  /// Set value using specific driver with fallback
  static Future<void> _setWithDriver<T>(
    String driver,
    String key,
    T value, {
    Duration? ttl,
  }) async {
    try {
      switch (driver) {
        case 'shared_prefs':
          if (_driverHealth['shared_prefs'] == true) {
            final serialized = CacheSerializer.serialize<T>(value);
            await _sharedPrefs!.setString(key, serialized);

            // Handle TTL if enabled
            if (ttl != null && _config?.enableTTL == true) {
              final expiry = DateTime.now().add(ttl);
              await _sharedPrefs!.setString(
                '${key}_ttl',
                expiry.millisecondsSinceEpoch.toString(),
              );
            }

            log('SharedPrefs SET: $key', name: 'Cache');
            return;
          }
          break;
        case 'memory':
          _memoryCache[key] = CacheSerializer.serialize<T>(value);

          // Handle TTL if enabled
          if (ttl != null && _config?.enableTTL == true) {
            _memoryTTL[key] = DateTime.now().add(ttl);
          }

          // Check size limits
          if (_memoryCache.length > (_config?.maxItemsPerDriver ?? 1000)) {
            _evictOldestMemoryItems();
          }

          log('Memory SET: $key', name: 'Cache');
          return;
      }

      // Fallback to memory
      if (_config?.logFallbacks == true) {
        log(
          'Driver $driver unavailable, falling back to memory',
          name: 'Cache',
        );
      }
      await _setWithDriver('memory', key, value, ttl: ttl);
    } catch (e) {
      if (_config?.logFallbacks == true) {
        log('Driver $driver failed, falling back to memory: $e', name: 'Cache');
      }
      await _setWithDriver('memory', key, value, ttl: ttl);
    }
  }

  /// Get value using specific driver
  static Future<T?> _getWithDriver<T>(String driver, String key) async {
    try {
      switch (driver) {
        case 'shared_prefs':
          if (_driverHealth['shared_prefs'] == true) {
            // Check TTL if enabled
            if (_config?.enableTTL == true) {
              final ttlString = _sharedPrefs!.getString('${key}_ttl');
              if (ttlString != null) {
                final expiry = DateTime.fromMillisecondsSinceEpoch(
                  int.parse(ttlString),
                );
                if (DateTime.now().isAfter(expiry)) {
                  await _sharedPrefs!.remove(key);
                  await _sharedPrefs!.remove('${key}_ttl');
                  log('SharedPrefs EXPIRED: $key', name: 'Cache');
                  return null;
                }
              }
            }

            final raw = _sharedPrefs!.getString(key);
            if (raw != null) {
              log('SharedPrefs HIT: $key', name: 'Cache');
              return CacheSerializer.deserialize<T>(raw);
            }
            log('SharedPrefs MISS: $key', name: 'Cache');
            return null;
          }
          break;
        case 'memory':
          // Check TTL if enabled
          if (_config?.enableTTL == true && _memoryTTL.containsKey(key)) {
            final expiry = _memoryTTL[key]!;
            if (DateTime.now().isAfter(expiry)) {
              _memoryCache.remove(key);
              _memoryTTL.remove(key);
              log('Memory EXPIRED: $key', name: 'Cache');
              return null;
            }
          }

          final raw = _memoryCache[key];
          if (raw != null) {
            log('Memory HIT: $key', name: 'Cache');
            return CacheSerializer.deserialize<T>(raw);
          }
          log('Memory MISS: $key', name: 'Cache');
          return null;
      }

      return null;
    } catch (e) {
      log('Driver $driver get failed: $e', name: 'Cache');
      return null;
    }
  }

  /// Check if key exists using specific driver
  static Future<bool> _hasWithDriver(String driver, String key) async {
    try {
      switch (driver) {
        case 'shared_prefs':
          return _driverHealth['shared_prefs'] == true &&
              _sharedPrefs!.containsKey(key);
        case 'memory':
          return _memoryCache.containsKey(key);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Remove key using specific driver
  static Future<void> _removeWithDriver(String driver, String key) async {
    try {
      switch (driver) {
        case 'shared_prefs':
          if (_driverHealth['shared_prefs'] == true) {
            await _sharedPrefs!.remove(key);
            await _sharedPrefs!.remove('${key}_ttl'); // Remove TTL if exists
            log('SharedPrefs REMOVE: $key', name: 'Cache');
          }
          break;
        case 'memory':
          _memoryCache.remove(key);
          _memoryTTL.remove(key);
          log('Memory REMOVE: $key', name: 'Cache');
          break;
      }
    } catch (e) {
      log('Driver $driver remove failed: $e', name: 'Cache');
    }
  }

  /// Clear all keys for specific driver
  static Future<void> _clearWithDriver(String driver) async {
    try {
      switch (driver) {
        case 'shared_prefs':
          if (_driverHealth['shared_prefs'] == true) {
            await _sharedPrefs!.clear();
            log('SharedPrefs CLEAR', name: 'Cache');
          }
          break;
        case 'memory':
          _memoryCache.clear();
          _memoryTTL.clear();
          log('Memory CLEAR', name: 'Cache');
          break;
      }
    } catch (e) {
      log('Driver $driver clear failed: $e', name: 'Cache');
    }
  }

  /// Get all keys for specific driver
  static Future<List<String>> _keysWithDriver(String driver) async {
    try {
      switch (driver) {
        case 'shared_prefs':
          if (_driverHealth['shared_prefs'] == true) {
            return _sharedPrefs!
                .getKeys()
                .where((key) => !key.endsWith('_ttl'))
                .toList();
          }
          break;
        case 'memory':
          return _memoryCache.keys.toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get cache size for specific driver
  static Future<int> _sizeWithDriver(String driver) async {
    try {
      switch (driver) {
        case 'shared_prefs':
          if (_driverHealth['shared_prefs'] == true) {
            return _sharedPrefs!
                .getKeys()
                .where((key) => !key.endsWith('_ttl'))
                .length;
          }
          break;
        case 'memory':
          return _memoryCache.length;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Evict oldest items from memory cache when size limit exceeded
  static void _evictOldestMemoryItems() {
    final keys = _memoryCache.keys.toList();
    final removeCount = keys.length - (_config?.maxItemsPerDriver ?? 1000) + 1;

    for (int i = 0; i < removeCount && i < keys.length; i++) {
      _memoryCache.remove(keys[i]);
      _memoryTTL.remove(keys[i]);
    }

    log('Memory cache evicted $removeCount items', name: 'Cache');
  }

  /// Validate cache key for production safety
  static bool _isValidKey(String key) {
    if (key.isEmpty) return false;
    if (key.length > (_config?.maxKeyLength ?? 250)) return false;
    if (key.contains('\n') || key.contains('\r')) return false;
    if (key.startsWith('_') || key.endsWith('_ttl')) {
      return false; // Reserved patterns
    }
    return true;
  }

  /// Sanitize and validate cache key
  static String _validateKey(String key) {
    if (!_isValidKey(key)) {
      final maxLength = _config?.maxKeyLength ?? 250;
      throw ArgumentError(
        'Invalid cache key: "$key". Keys must be non-empty, under $maxLength characters, '
        'without newlines, and not start with underscore or end with "_ttl".',
      );
    }
    return key;
  }
}

/*
 * CacheSecureProxy - Secure cache operations
 */
class CacheSecureProxy {
  CacheSecureProxy._();

  /// Store secure value with optional TTL
  Future<void> set<T>(String key, T value, {Duration? ttl}) async {
    Cache._validateKey(key); // Validate key before processing
    try {
      if (Cache._driverHealth['secure_storage'] == true) {
        final serialized = CacheSerializer.serialize<T>(value);
        await Cache._secureStorage!.write(key: key, value: serialized);

        // Handle TTL if enabled
        if (ttl != null && Cache._config?.enableTTL == true) {
          final expiry = DateTime.now().add(ttl);
          await Cache._secureStorage!.write(
            key: '${key}_ttl',
            value: expiry.millisecondsSinceEpoch.toString(),
          );
        }

        log('SecureStorage SET: $key', name: 'Cache');
      } else {
        // Fallback to memory with warning
        if (Cache._config?.logFallbacks == true) {
          log(
            'WARNING: SecureStorage unavailable, using memory fallback for: $key',
            name: 'Cache',
          );
        }
        await Cache._setWithDriver('memory', key, value, ttl: ttl);
      }
    } catch (e) {
      if (Cache._config?.logFallbacks == true) {
        log('SecureStorage failed, using memory fallback: $e', name: 'Cache');
      }
      await Cache._setWithDriver('memory', key, value, ttl: ttl);
    }
  }

  /// Get secure value
  Future<T?> get<T>(String key) async {
    Cache._validateKey(key); // Validate key before processing
    try {
      if (Cache._driverHealth['secure_storage'] == true) {
        final raw = await Cache._secureStorage!.read(key: key);
        if (raw != null) {
          log('SecureStorage HIT: $key', name: 'Cache');
          return CacheSerializer.deserialize<T>(raw);
        }
        log('SecureStorage MISS: $key', name: 'Cache');
        return null;
      } else {
        return await Cache._getWithDriver<T>('memory', key);
      }
    } catch (e) {
      log('SecureStorage get failed, trying memory: $e', name: 'Cache');
      return await Cache._getWithDriver<T>('memory', key);
    }
  }

  /// Check if secure key exists
  Future<bool> has(String key) async {
    Cache._validateKey(key); // Validate key before processing
    try {
      if (Cache._driverHealth['secure_storage'] == true) {
        return await Cache._secureStorage!.containsKey(key: key);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Remove secure key
  Future<void> remove(String key) async {
    Cache._validateKey(key); // Validate key before processing
    try {
      if (Cache._driverHealth['secure_storage'] == true) {
        await Cache._secureStorage!.delete(key: key);
        await Cache._secureStorage!.delete(key: '${key}_ttl');
        log('SecureStorage REMOVE: $key', name: 'Cache');
      }
    } catch (e) {
      log('SecureStorage remove failed: $e', name: 'Cache');
    }
  }

  /// Clear all secure keys
  Future<void> clear() async {
    try {
      if (Cache._driverHealth['secure_storage'] == true) {
        await Cache._secureStorage!.deleteAll();
        log('SecureStorage CLEAR', name: 'Cache');
      }
    } catch (e) {
      log('SecureStorage clear failed: $e', name: 'Cache');
    }
  }
}
