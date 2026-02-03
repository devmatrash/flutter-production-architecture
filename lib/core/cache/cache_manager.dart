import 'dart:developer';

import 'package:flutter_production_architecture/core/cache/cache_config.dart';
import 'package:flutter_production_architecture/core/cache/cache_drivers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages cache driver lifecycle and selection
class CacheManager {
  final Map<CacheDriverType, CacheDriver> _drivers = {};
  CacheDriver? _defaultDriver;
  CacheConfig? _config;

  CacheConfig? get config => _config;

  Future<void> initialize({
    String? defaultDriver,
    CacheConfig? config,
  }) async {
    _config = config ?? CacheConfig.defaults();
    await _initializeDrivers();

    final driverType = CacheDriverType.fromString(defaultDriver);
    _defaultDriver = (driverType != null ? _drivers[driverType] : null) ??
        _drivers[CacheDriverType.memory];
    log('Cache initialized with driver: ${_defaultDriver?.name}',
        name: 'Cache');
  }

  Future<void> _initializeDrivers() async {
    _drivers[CacheDriverType.memory] = MemoryDriver();

    try {
      final prefs = await SharedPreferences.getInstance();
      _drivers[CacheDriverType.sharedPrefs] = SharedPrefsDriver(prefs);
      log('SharedPreferences driver available', name: 'Cache');
    } catch (e) {
      if (_config?.logFallbacks == true) {
        log('SharedPreferences unavailable: $e', name: 'Cache');
      }
    }

    try {
      final storage = const FlutterSecureStorage(
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );
      _drivers[CacheDriverType.secureStorage] = SecureStorageDriver(storage);
      log('SecureStorage driver available', name: 'Cache');
    } catch (e) {
      if (_config?.logFallbacks == true) {
        log('SecureStorage unavailable: $e', name: 'Cache');
      }
    }
  }

  CacheDriver getDriver(String? driverName) {
    if (driverName != null) {
      final driverType = CacheDriverType.fromString(driverName);
      if (driverType != null && _drivers.containsKey(driverType)) {
        final driver = _drivers[driverType]!;
        if (driver.isAvailable) return driver;

        if (_config?.logFallbacks == true) {
          log('Driver $driverName unavailable, using memory', name: 'Cache');
        }
      }
    }
    return _defaultDriver ?? _drivers[CacheDriverType.memory]!;
  }

  Future<Map<String, dynamic>> getStats(
      Future<int> Function(String driver) getSizeFunc) async {
    final stats = <String, dynamic>{
      'defaultDriver': _defaultDriver?.name,
      'availableDrivers': _drivers.keys.map((e) => e.value).toList(),
      'driverHealth': {
        for (final entry in _drivers.entries)
          entry.key.value: entry.value.isAvailable
      },
    };

    for (final entry in _drivers.entries) {
      final driverSize = await getSizeFunc(entry.key.value);
      stats['${entry.key.value}Size'] = driverSize;
    }

    stats['config'] = _config.toString();
    return stats;
  }

  bool get isInitialized => _defaultDriver != null;
  String? get defaultDriver => _defaultDriver?.name;
  Map<String, bool> get driverHealth =>
      {for (final e in _drivers.entries) e.key.value: e.value.isAvailable};

  Map<CacheDriverType, CacheDriver> get drivers => _drivers;

  Future<void> clearAllDrivers() async {
    for (final driver in _drivers.values) {
      await driver.clear();
    }
  }
}
