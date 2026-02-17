import 'dart:developer';

import 'package:flutter_production_architecture/core/navigation/data/repositories/navigation_event_bus_impl.dart';
import 'package:flutter_production_architecture/core/navigation/domain/repositories/i_navigation_event_bus.dart';
import 'package:flutter_production_architecture/core/navigation/infrastructure/adapters/auto_route_observer_adapter.dart';
import 'package:flutter_production_architecture/core/navigation/infrastructure/listeners/logging_navigation_listener.dart';
import 'package:flutter_production_architecture/core/providers/service_provider.dart';
import 'package:get_it/get_it.dart';

/// Service provider for the navigation observability system
///
/// Registers all navigation-related services in the dependency injection container:
/// - Event bus (INavigationEventBus)
/// - Route observer adapter (AutoRouteObserverAdapter)
/// - Navigation listeners (LoggingNavigationListener, etc.)
///
/// The registration follows a specific order:
/// 1. Register event bus (core infrastructure)
/// 2. Register observer adapter (depends on event bus)
/// 3. Register and start listeners (consume events from bus)
///
/// Listeners are conditionally registered based on environment:
/// - LoggingNavigationListener: Always registered
/// - Debug listeners: Only in kDebugMode
/// - Analytics listeners: Based on feature flags (Phase 4)
///
/// Example:
/// ```dart
/// // In app_run_providers.dart
/// final List<ServiceProvider> appRunProviders = [
///   CacheServiceProvider(),
///   NavigationServiceProvider(), // Add this
/// ];
/// ```
class NavigationServiceProvider implements ServiceProvider {
  @override
  Future<void> register(GetIt it) async {
    log(
      'Registering navigation observability system',
      name: 'NavigationServiceProvider',
    );

    // Register event bus as lazy singleton
    // Lazy: Created only when first accessed (after WidgetsBinding initialized)
    it.registerLazySingleton<INavigationEventBus>(
      () => NavigationEventBusImpl(),
    );

    log('Event bus registered', name: 'NavigationServiceProvider');

    // Register observer adapter as lazy singleton
    // This will be injected into the router's navigatorObservers
    it.registerLazySingleton<AutoRouteObserverAdapter>(
      () => AutoRouteObserverAdapter(it<INavigationEventBus>()),
    );

    log('Observer adapter registered', name: 'NavigationServiceProvider');

    // Register and start listeners
    await _registerListeners(it);

    log(
      'Navigation observability system registered successfully',
      name: 'NavigationServiceProvider',
    );
  }

  /// Register navigation listeners and start them immediately
  ///
  /// Listeners are registered as singletons so they can be accessed later
  /// for health checks or manual start/stop (if needed).
  ///
  /// Each listener starts immediately after registration to begin
  /// capturing navigation events from app launch.
  Future<void> _registerListeners(GetIt it) async {
    log('Registering navigation listeners', name: 'NavigationServiceProvider');

    // Get event bus (will be created on first access)
    final eventBus = it<INavigationEventBus>();

    // Always register logging listener (production + development)
    log('Registering LoggingNavigationListener', name: 'NavigationServiceProvider');
    final loggingListener = LoggingNavigationListener();
    loggingListener.startListening(eventBus);
    it.registerSingleton<LoggingNavigationListener>(loggingListener);

    // In debug mode, we could add additional listeners here
    // Example:
    // if (kDebugMode) {
    //   final debugListener = DebugNavigationListener();
    //   debugListener.startListening(eventBus);
    //   it.registerSingleton<DebugNavigationListener>(debugListener);
    // }

    // Future Phase 4: Analytics listener registration
    // This will be enabled via feature flags or configuration
    // Example:
    // if (config.analyticsEnabled) {
    //   final analyticsListener = AnalyticsNavigationListener(
    //     firebaseAnalytics: it<FirebaseAnalytics>(),
    //   );
    //   analyticsListener.startListening(eventBus);
    //   it.registerSingleton<AnalyticsNavigationListener>(analyticsListener);
    // }

    log(
      'Navigation listeners registered and started',
      name: 'NavigationServiceProvider',
    );
  }
}


