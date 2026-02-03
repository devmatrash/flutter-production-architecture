import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_production_architecture/core/bootstrap/bootstrap_delegates.dart';
import 'package:flutter_production_architecture/core/cache/cache.dart';
import 'package:flutter_production_architecture/core/cache/cache_service_provider.dart';
import 'package:flutter_production_architecture/core/lifecycle/app_lifecycle.dart';

/*
 * Handles application bootstrap lifecycle and error management.
 *
 * This class manages the three critical phases of app initialization:
 * - beforeRunApp: Pre-flight checks and setup
 * - runApp: Main application launch
 * - afterRunApp: Post-launch configuration and error handlers
 *
 * Error handling strategy:
 * - Uses runZonedGuarded to catch uncaught async errors
 * - Routes all errors through onAppError for centralized processing
 */
class AppBootstrap extends BootstrapDelegates {
  @override
  Future<void> beforeRunApp(WidgetsBinding widgetsBinding) async {
    log('START: beforeRunApp', name: 'AppBootstrap');

    // Initialize AppLifeCycle observer
    await AppLifeCycle.instance.initialize();

    log('END: beforeRunApp', name: 'AppBootstrap');
  }

  @override
  Future<void> afterRunApp() async {
    log('START: afterRunApp', name: 'AppBootstrap');

    // Verify AppLifeCycle is initialized
    if (AppLifeCycle.instance.isInitialized) {
      log(
        'AppLifeCycle successfully initialized and monitoring',
        name: 'AppBootstrap',
      );
    } else {
      log('Warning: AppLifeCycle failed to initialize', name: 'AppBootstrap');
    }

    // Initialize enhanced cache system with production monitoring
    try {
      log('Initializing enhanced cache system...', name: 'AppBootstrap');
      await CacheServiceProvider.initializeCache();
      log('✅ Cache system initialized successfully', name: 'AppBootstrap');

      // PRODUCTION HEALTH CHECK: Verify cache functionality
      await _performEnhancedCacheHealthCheck();
    } catch (e, stackTrace) {
      log(
        'CRITICAL: Cache system initialization failed: $e',
        name: 'AppBootstrap',
      );
      log('Stack trace: $stackTrace', name: 'AppBootstrap');
      log(
        'WARNING: App will continue but cache functionality may be degraded',
        name: 'AppBootstrap',
      );
      // Don't rethrow - let app continue but cache won't work optimally
    }

    log('END: afterRunApp', name: 'AppBootstrap');
  }

  /// Performs comprehensive health check for enhanced driver-based cache system
  Future<void> _performEnhancedCacheHealthCheck() async {
    try {
      log('Performing enhanced cache health check', name: 'AppBootstrap');

      if (!Cache.isInitialized) {
        log('Cache not properly initialized', name: 'AppBootstrap');
        return;
      }

      // Get comprehensive cache statistics
      final stats = await Cache.getStats();
      log('Cache Statistics: $stats', name: 'AppBootstrap');

      // Test default driver functionality
      const testKey = 'bootstrap_health_check';
      const testValue = 'success';

      // Test regular cache with default driver
      await Cache.set<String>(testKey, testValue);
      final retrievedValue = await Cache.get<String>(testKey);

      if (retrievedValue == testValue) {
        log(
          'Default cache driver functional test passed',
          name: 'AppBootstrap',
        );
        await Cache.remove(testKey); // Clean up
      } else {
        log(
          'Default cache driver functional test failed',
          name: 'AppBootstrap',
        );
      }

      // Test secure cache functionality
      await Cache.secure.set<String>(testKey, testValue);
      final secureRetrieved = await Cache.secure.get<String>(testKey);

      if (secureRetrieved == testValue) {
        log('Secure cache functional test passed', name: 'AppBootstrap');
        await Cache.secure.remove(testKey); // Clean up
      } else {
        log('Secure cache functional test failed', name: 'AppBootstrap');
      }

      // Test driver override functionality
      await Cache.set<String>(testKey, testValue, driver: 'memory');
      final memoryRetrieved = await Cache.get<String>(
        testKey,
        driver: 'memory',
      );

      if (memoryRetrieved == testValue) {
        log('Driver override functional test passed', name: 'AppBootstrap');
        await Cache.remove(testKey, driver: 'memory'); // Clean up
      } else {
        log('Driver override functional test failed', name: 'AppBootstrap');
      }

      // Log driver health status
      final driverHealth = Cache.driverHealth;
      log('Driver Health Status: $driverHealth', name: 'AppBootstrap');

      // Alert about fallback usage
      if (Cache.defaultDriver == 'memory') {
        log(
          'WARNING: Using memory as default driver - check platform storage',
          name: 'AppBootstrap',
        );
      }
    } catch (e) {
      log('Enhanced cache health check failed: $e', name: 'AppBootstrap');
    }
  }

  @override
  Future<void> onAppError(Object error, StackTrace stack) async {
    log("Error Type : ${error.runtimeType}", name: 'AppBootstrap');
    log('Error: $error', stackTrace: stack, name: 'AppBootstrap');
  }
}
