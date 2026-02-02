import 'package:flutter_production_architecture/core/bootstrap/app_bootstrap.dart';
import 'package:flutter_production_architecture/core/providers/service_provider.dart';
import 'package:get_it/get_it.dart';

/*
 * CoreServiceProvider - Registers core application services
 *
 * This provider is responsible for registering essential services that are
 * needed throughout the application lifecycle, including:
 * - AppBootstrap: Handles app initialization and lifecycle management
 *
 * Registration Strategy:
 * - AppBootstrap is registered as a singleton since it manages global app state
 * - Can be extended to register other core services like error handlers,
 *   configuration services, etc.
 */
class CoreServiceProvider implements ServiceProvider {
  @override
  Future<void> register(GetIt it) async {
    // Register AppBootstrap as singleton
    // This ensures the same instance is used throughout the app lifecycle
    it.registerSingleton<AppBootstrap>(AppBootstrap());

    // Future core services can be registered here:
    // it.registerSingleton<ErrorHandler>(ErrorHandler());
    // it.registerSingleton<ConfigService>(ConfigService());
  }
}
