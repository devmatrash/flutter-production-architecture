import 'dart:developer';

import 'package:flutter_production_architecture/core/cache/presentation/cache_facade.dart';
import 'package:flutter_production_architecture/core/cache/domain/entities/cache_config.dart';
import 'package:flutter_production_architecture/core/providers/service_provider.dart';
import 'package:get_it/get_it.dart';

/*
 * CacheServiceProvider - Enhanced cache service provider with driver-based architecture
 *
 * Features:
 * - Circuit breaker pattern with automatic fallback to memory
 * - Production-ready configuration management
 * - Comprehensive error handling and logging
 * - Driver health monitoring and fallback alerts
 */
class CacheServiceProvider implements ServiceProvider {
  @override
  Future<void> register(GetIt it) async {
    // Register a factory for cache initialization that will be called later
    // This avoids the MissingPluginException by deferring SharedPreferences access
    it.registerLazySingleton<Future<void> Function()>(
      () => initializeCache,
      instanceName: 'cacheInitializer',
    );
  }

  /// Enhanced cache initialization with production configuration and fallbacks
  static Future<void> initializeCache() async {
    log('Starting enhanced cache initialization', name: 'CacheServiceProvider');

    try {
      // Initialize with shared_prefs as default
      await Cache.initialize(
        defaultDriver: 'shared_prefs',
        config: CacheConfig.defaults(),
      );

      // Log initialization success and driver status
      final stats = await Cache.getStats();
      log(
        'Cache initialization completed successfully',
        name: 'CacheServiceProvider',
      );
      log('Cache Status: $stats', name: 'CacheServiceProvider');

      // Alert if using fallback drivers
      final driverHealth = Cache.driverHealth;
      if (driverHealth['shared_prefs'] != true) {
        log(
          'OPERATIONAL ALERT: SharedPreferences unavailable - using memory fallback',
          name: 'CacheServiceProvider',
        );
        log(
          'This may indicate iOS Simulator, plugin issues, or CI environment',
          name: 'CacheServiceProvider',
        );
      }

      if (driverHealth['secure_storage'] != true) {
        log(
          'WARNING: FlutterSecureStorage unavailable - secure data will use memory fallback',
          name: 'CacheServiceProvider',
        );
      }
    } catch (e, stackTrace) {
      log(
        'CRITICAL: Cache initialization failed: $e',
        name: 'CacheServiceProvider',
      );
      log('Stack trace: $stackTrace', name: 'CacheServiceProvider');

      // Emergency fallback - try memory-only initialization
      try {
        log(
          'Attempting emergency memory-only initialization',
          name: 'CacheServiceProvider',
        );

        await Cache.initialize(
          defaultDriver: 'memory',
          config: CacheConfig(
            enableTTL: false, // Disable TTL for emergency mode
            logFallbacks: true, // Keep logging enabled
          ),
        );

        log(
          'Emergency cache initialized - ALL data is temporary',
          name: 'CacheServiceProvider',
        );
        log(
          'CRITICAL: Platform storage completely unavailable',
          name: 'CacheServiceProvider',
        );
      } catch (emergencyError) {
        log(
          'FATAL: Even emergency cache initialization failed: $emergencyError',
          name: 'CacheServiceProvider',
        );
        rethrow; // If even memory cache fails, something is fundamentally wrong
      }
    }
  }
}
