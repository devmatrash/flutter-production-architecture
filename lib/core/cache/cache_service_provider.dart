import 'dart:developer';

import 'package:flutter_production_architecture/core/cache/cache.dart';
import 'package:flutter_production_architecture/core/cache/regular_cache.dart';
import 'package:flutter_production_architecture/core/cache/secure_cache.dart';
import 'package:flutter_production_architecture/core/providers/service_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
 * CacheServiceProvider - Prepares cache services for later initialization
 *
 * Note: Actual cache initialization is deferred to the bootstrap phase
 * to ensure Flutter plugins are fully initialized before accessing SharedPreferences.
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

  /// Cache initialization function - called during bootstrap phase
  static Future<void> initializeCache() async {
    try {
      log('Cache initialization process...', name: 'CacheServiceProvider');
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      log('Initializing FlutterSecureStorage...', name: 'CacheServiceProvider');

      // Initialize FlutterSecureStorage
      const secureStorage = FlutterSecureStorage(
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );

      log(
        'Creating cache storage implementations...',
        name: 'CacheServiceProvider',
      );

      // Create cache storage implementations
      final regularStorage = RegularCache(sharedPreferences);
      final secureStorageImpl = SecureCache(secureStorage);

      log('Initializing Cache class...', name: 'CacheServiceProvider');

      // Initialize the static Cache class
      Cache.initialize(
        regularStorage: regularStorage,
        secureStorage: secureStorageImpl,
      );

      log(
        'Cache initialization completed successfully',
        name: 'CacheServiceProvider',
      );
    } catch (e, stackTrace) {
      // Log the error but don't crash the app
      log('Failed to initialize cache: $e', name: 'CacheServiceProvider');
      log('Stack trace: $stackTrace', name: 'CacheServiceProvider');
      rethrow;
    }
  }
}
