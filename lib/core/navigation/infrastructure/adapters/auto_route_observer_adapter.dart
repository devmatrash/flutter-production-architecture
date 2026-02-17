import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_production_architecture/core/navigation/domain/entities/navigation_event.dart';
import 'package:flutter_production_architecture/core/navigation/domain/entities/route_info.dart';
import 'package:flutter_production_architecture/core/navigation/domain/enums/navigation_event_type.dart';
import 'package:flutter_production_architecture/core/navigation/domain/repositories/i_navigation_event_bus.dart';

/// Adapter that bridges auto_route's RouteObserver to our domain layer
///
/// This class is the ONLY place in the navigation system where auto_route
/// types are directly referenced. All other layers work with domain entities.
///
/// Architecture Benefits:
/// - Isolates auto_route dependency (easy to swap routers)
/// - Converts router-specific types to platform-agnostic domain entities
/// - Enables testing without auto_route dependency
/// - Maintains Clean Architecture boundaries
///
/// Performance Optimization:
/// - Only constructs events if listeners are active (lazy evaluation)
/// - Shallow argument extraction (top-level keys only)
/// - Non-blocking event publishing (async stream)
///
/// Example Usage:
/// ```dart
/// // In HandbookApp
/// MaterialApp.router(
///   routerDelegate: _appRouter.delegate(
///     navigatorObservers: () => [
///       inject.sl<AutoRouteObserverAdapter>(),
///     ],
///   ),
/// )
/// ```
class AutoRouteObserverAdapter extends AutoRouteObserver {
  final INavigationEventBus _eventBus;

  /// Create adapter with injected event bus
  ///
  /// The event bus is injected via dependency injection to maintain
  /// testability and follow the Dependency Inversion Principle.
  AutoRouteObserverAdapter(this._eventBus) {
    log('AutoRouteObserverAdapter initialized', name: 'Navigation');
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _publishEvent(
      type: NavigationEventType.push,
      route: route,
      previousRoute: previousRoute,
    );
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _publishEvent(
      type: NavigationEventType.pop,
      route: route,
      previousRoute: previousRoute,
    );
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute == null) return;

    _publishEvent(
      type: NavigationEventType.replace,
      route: newRoute,
      previousRoute: oldRoute,
    );
  }

  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {
    // TabPageRoute extends PageRouteInfo, cast to Route for our method
    _publishEvent(
      type: NavigationEventType.tabChange,
      route: route as Route,
      previousRoute: previousRoute as Route?,
    );
  }

  /// Publish a navigation event to the event bus
  ///
  /// Performance optimization: Only constructs the event if there are
  /// active listeners. This avoids expensive argument extraction when
  /// no one is listening.
  void _publishEvent({
    required NavigationEventType type,
    required Route route,
    Route? previousRoute,
  }) {
    // Performance optimization: Skip if no listeners
    if (!_eventBus.hasActiveListeners) {
      return;
    }

    try {
      final event = NavigationEvent(
        type: type,
        from: previousRoute != null ? _extractRouteInfo(previousRoute) : null,
        to: _extractRouteInfo(route),
        arguments: _extractArguments(route),
        timestamp: DateTime.now(),
        // sessionId will be populated in Phase 4 (Session Tracking)
      );

      _eventBus.publish(event);
    } catch (e, stack) {
      // Catch errors to prevent navigation crashes
      // Log but don't rethrow - observer errors shouldn't break navigation
      log(
        'Error creating navigation event: $e',
        name: 'AutoRouteObserverAdapter',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Extract platform-agnostic route information from Route
  ///
  /// Handles both:
  /// - PageRouteInfo (auto_route specific)
  /// - Standard Flutter Route
  ///
  /// Returns a [RouteInfo] entity with no auto_route dependencies.
  RouteInfo _extractRouteInfo(Route route) {
    try {
      // Extract route name
      String name = 'UnknownRoute';
      String path = '/unknown';

      // Try to get name from route settings
      if (route.settings.name != null && route.settings.name!.isNotEmpty) {
        name = route.settings.name!;
        path = route.settings.name!;
      }

      // For auto_route PageRouteInfo, extract more detailed information
      if (route is PageRoute) {
        // Page routes typically have better metadata
        final routeName = route.settings.name;
        if (routeName != null && routeName.isNotEmpty) {
          name = routeName;
          path = routeName;

          // Clean up route name (remove leading slash if present)
          if (name.startsWith('/') && name.length > 1) {
            name = name.substring(1);
          }
        }
      }

      return RouteInfo(
        name: name,
        path: path,
        // Parameters extracted separately in _extractArguments
        // to maintain shallow extraction strategy
      );
    } catch (e, stack) {
      log(
        'Error extracting route info: $e',
        name: 'AutoRouteObserverAdapter',
        error: e,
        stackTrace: stack,
      );

      // Return fallback route info to prevent crashes
      return const RouteInfo(
        name: 'ErrorRoute',
        path: '/error',
      );
    }
  }

  /// Extract route arguments with shallow serialization
  ///
  /// Strategy: Top-level keys only (no deep traversal)
  /// Rationale: Performance optimization + privacy
  ///
  /// Sanitization: Sensitive keys are redacted in production
  ///
  /// Returns null if:
  /// - No arguments present
  /// - Arguments cannot be safely extracted
  /// - Extraction throws an error
  Map<String, dynamic>? _extractArguments(Route route) {
    try {
      final args = route.settings.arguments;
      if (args == null) return null;

      // If already a Map, sanitize and return
      if (args is Map<String, dynamic>) {
        return _sanitizeArguments(args);
      }

      // If it's a Map with different types, convert
      if (args is Map) {
        final converted = <String, dynamic>{};
        args.forEach((key, value) {
          if (key is String) {
            converted[key] = value;
          }
        });
        return _sanitizeArguments(converted);
      }

      // For non-map arguments, wrap in a generic key
      return {'value': args.toString()};
    } catch (e, stack) {
      log(
        'Error extracting route arguments: $e',
        name: 'AutoRouteObserverAdapter',
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }

  /// Sanitize sensitive data from arguments
  ///
  /// Redacts values for known sensitive keys to prevent accidental logging
  /// of passwords, tokens, API keys, etc.
  ///
  /// This is a defense-in-depth measure - listeners should also sanitize,
  /// but we do it here as early as possible.
  Map<String, dynamic> _sanitizeArguments(Map<String, dynamic> args) {
    final sanitized = <String, dynamic>{};

    args.forEach((key, value) {
      if (_isSensitiveKey(key)) {
        sanitized[key] = '[REDACTED]';
      } else {
        // Shallow copy only - don't traverse nested structures
        sanitized[key] = value;
      }
    });

    return sanitized;
  }

  /// Check if a key name indicates sensitive data
  ///
  /// Uses case-insensitive matching of common sensitive field names.
  bool _isSensitiveKey(String key) {
    final lowerKey = key.toLowerCase();
    const sensitivePatterns = [
      'token',
      'password',
      'passwd',
      'pwd',
      'secret',
      'apikey',
      'api_key',
      'auth',
      'credential',
      'private',
      'ssn',
      'credit',
      'card',
      'cvv',
    ];

    return sensitivePatterns.any((pattern) => lowerKey.contains(pattern));
  }
}

