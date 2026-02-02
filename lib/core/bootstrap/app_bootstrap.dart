import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_production_architecture/core/bootstrap/bootstrap_delegates.dart';
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
    log('beforeRunApp', name: 'AppBootstrap');

    // Initialize AppLifeCycle observer
    await AppLifeCycle.instance.initialize();
  }

  @override
  Future<void> afterRunApp() async {
    log('afterRunApp', name: 'AppBootstrap');

    // Verify AppLifeCycle is initialized
    if (AppLifeCycle.instance.isInitialized) {
      log(
        'AppLifeCycle successfully initialized and monitoring',
        name: 'AppBootstrap',
      );
    } else {
      log('Warning: AppLifeCycle failed to initialize', name: 'AppBootstrap');
    }
  }

  @override
  Future<void> onAppError(Object error, StackTrace stack) async {
    log("Error Type : ${error.runtimeType}", name: 'AppBootstrap');
    log('Error: $error', stackTrace: stack, name: 'AppBootstrap');
  }
}
