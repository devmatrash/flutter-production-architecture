import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_production_architecture/core/navigation/domain/entities/navigation_event.dart';
import 'package:flutter_production_architecture/core/navigation/domain/entities/route_info.dart';
import 'package:flutter_production_architecture/core/navigation/domain/enums/navigation_event_type.dart';
import 'package:flutter_production_architecture/core/navigation/domain/repositories/i_navigation_event_bus.dart';

/// Adapter that bridges auto_route's RouteObserver to our domain layer
class AutoRouteObserverAdapter extends AutoRouteObserver {
  final INavigationEventBus _eventBus;

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
    _publishEvent(
      type: NavigationEventType.tabChange,
      route: route as Route,
      previousRoute: previousRoute as Route?,
    );
  }

  /// Publish navigation event (skips if no listeners for performance)
  void _publishEvent({
    required NavigationEventType type,
    required Route route,
    Route? previousRoute,
  }) {
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
      );

      _eventBus.publish(event);
    } catch (e, stack) {
      log(
        'Error creating navigation event: $e',
        name: 'AutoRouteObserverAdapter',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Extract platform-agnostic route info from Route
  RouteInfo _extractRouteInfo(Route route) {
    try {
      String name = 'UnknownRoute';
      String path = '/unknown';

      if (route.settings.name != null && route.settings.name!.isNotEmpty) {
        name = route.settings.name!;
        path = route.settings.name!;
      }

      if (route is PageRoute) {
        final routeName = route.settings.name;
        if (routeName != null && routeName.isNotEmpty) {
          name = routeName;
          path = routeName;

          if (name.startsWith('/') && name.length > 1) {
            name = name.substring(1);
          }
        }
      }

      return RouteInfo(
        name: name,
        path: path,
      );
    } catch (e, stack) {
      log(
        'Error extracting route info: $e',
        name: 'AutoRouteObserverAdapter',
        error: e,
        stackTrace: stack,
      );

      return const RouteInfo(
        name: 'ErrorRoute',
        path: '/error',
      );
    }
  }

  /// Extract route arguments with shallow serialization and sanitization
  Map<String, dynamic>? _extractArguments(Route route) {
    try {
      final args = route.settings.arguments;
      if (args == null) return null;

      if (args is Map<String, dynamic>) {
        return _sanitizeArguments(args);
      }

      if (args is Map) {
        final converted = <String, dynamic>{};
        args.forEach((key, value) {
          if (key is String) {
            converted[key] = value;
          }
        });
        return _sanitizeArguments(converted);
      }

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

  /// Sanitize sensitive data (redacts passwords, tokens, etc.)
  Map<String, dynamic> _sanitizeArguments(Map<String, dynamic> args) {
    final sanitized = <String, dynamic>{};

    args.forEach((key, value) {
      if (_isSensitiveKey(key)) {
        sanitized[key] = '[REDACTED]';
      } else {
        sanitized[key] = value;
      }
    });

    return sanitized;
  }

  /// Check if key name indicates sensitive data
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

