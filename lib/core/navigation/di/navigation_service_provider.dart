import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_production_architecture/core/navigation/data/repositories/navigation_event_bus_impl.dart';
import 'package:flutter_production_architecture/core/navigation/domain/entities/argument_sanitization_config.dart';
import 'package:flutter_production_architecture/core/navigation/domain/repositories/i_navigation_event_bus.dart';
import 'package:flutter_production_architecture/core/navigation/infrastructure/adapters/auto_route_observer_adapter.dart';
import 'package:flutter_production_architecture/core/navigation/infrastructure/listeners/logging_navigation_listener.dart';
import 'package:flutter_production_architecture/core/providers/service_provider.dart';
import 'package:get_it/get_it.dart';

/// Registers navigation observability system components
class NavigationServiceProvider implements ServiceProvider {
  @override
  Future<void> register(GetIt it) async {
    log('Initializing navigation observability', name: 'NavigationServiceProvider');

    it.registerLazySingleton<INavigationEventBus>(() => NavigationEventBusImpl());

    final sanitizationConfig = kDebugMode
        ? ArgumentSanitizationConfig.disabled()
        : ArgumentSanitizationConfig.strict;

    it.registerLazySingleton<AutoRouteObserverAdapter>(
      () => AutoRouteObserverAdapter(
        it<INavigationEventBus>(),
        sanitizationConfig,
      ),
    );

    await _registerListeners(it);
  }

  Future<void> _registerListeners(GetIt it) async {
    final eventBus = it<INavigationEventBus>();

    final loggingListener = LoggingNavigationListener();
    loggingListener.startListening(eventBus);
    it.registerSingleton<LoggingNavigationListener>(loggingListener);
  }
}


