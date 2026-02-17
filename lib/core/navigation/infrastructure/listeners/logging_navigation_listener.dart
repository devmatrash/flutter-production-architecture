import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_production_architecture/core/navigation/domain/entities/navigation_event.dart';
import 'package:flutter_production_architecture/core/navigation/domain/repositories/i_navigation_event_bus.dart';
import 'package:flutter_production_architecture/core/navigation/domain/repositories/i_navigation_listener.dart';

/// Logs navigation events using structured logging
///
/// This is the primary navigation listener for development and production monitoring.
/// It outputs navigation events to the console using Dart's developer log API.
///
/// Features:
/// - Structured logging with consistent format
/// - Development vs production modes (different verbosity)
/// - Error isolation (errors don't affect other listeners)
/// - Arguments logging (dev only for privacy)
/// - Performance timing indicators
///
/// Log Format:
/// ```
/// [Navigation] Navigation: SplashRoute → HomeRoute (push)
/// [Navigation]   Arguments: {userId: 123, mode: edit}  // dev only
/// [Navigation]   Timestamp: 2026-02-17T10:30:45.123Z
/// ```
///
/// Usage:
/// This listener is automatically registered by [NavigationServiceProvider]
/// and starts listening immediately after app initialization.
class LoggingNavigationListener implements INavigationListener {
  @override
  String get name => 'LoggingNavigationListener';

  StreamSubscription<NavigationEvent>? _subscription;

  @override
  void startListening(INavigationEventBus eventBus) {
    if (_subscription != null) {
      log(
        'Warning: $name already listening',
        name: 'Navigation',
      );
      return;
    }

    _subscription = eventBus.subscribe().listen(
      _onNavigationEvent,
      onError: _onError,
      cancelOnError: false, // Continue listening even if errors occur
    );

    log('$name started', name: 'Navigation');
  }

  /// Handle incoming navigation event
  ///
  /// Logs event details in debug mode only. In production, the listener remains
  /// registered but silent to avoid log noise and optimize performance.
  void _onNavigationEvent(NavigationEvent event) {
    // Skip logging entirely in production builds
    if (!kDebugMode) return;

    try {
      // Basic navigation log
      final fromRoute = event.from?.name ?? 'App Start';
      log(
        'Navigation: $fromRoute → ${event.to.name} (${event.type.value})',
        name: 'Navigation',
      );

      // Additional details
      _logDebugDetails(event);
    } catch (e, stack) {
      // Catch errors in logging to prevent affecting navigation
      log(
        'Error in $name while logging event: $e',
        name: 'Navigation',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Log detailed event information (debug mode only)
  ///
  /// Includes:
  /// - Route paths
  /// - Arguments (if present)
  /// - Timestamp
  /// - Session ID (when implemented)
  void _logDebugDetails(NavigationEvent event) {
    // Log full path information
    if (event.from != null) {
      log('  From: ${event.from!.path}', name: 'Navigation', level: 500);
    }
    log('  To: ${event.to.path}', name: 'Navigation', level: 500);

    // Log arguments if present
    if (event.arguments != null && event.arguments!.isNotEmpty) {
      log('  Arguments: ${event.arguments}', name: 'Navigation', level: 500);
    }

    // Log timestamp for timing analysis
    log(
      '  Timestamp: ${event.timestamp.toIso8601String()}',
      name: 'Navigation',
      level: 500,
    );

    // Log session ID if available (Phase 4 feature)
    if (event.sessionId != null) {
      log('  Session: ${event.sessionId}', name: 'Navigation', level: 500);
    }
  }

  /// Handle errors in the event stream
  ///
  /// This should rarely occur, but we log it to help diagnose issues
  /// with the event bus or listener implementation.
  void _onError(Object error, StackTrace stack) {
    log(
      'Error in $name event stream: $error',
      name: 'Navigation',
      error: error,
      stackTrace: stack,
    );
  }

  @override
  Future<void> stopListening() async {
    if (_subscription == null) {
      log(
        'Warning: $name not currently listening',
        name: 'Navigation',
      );
      return;
    }

    try {
      await _subscription!.cancel();
      _subscription = null;
      log('$name stopped', name: 'Navigation');
    } catch (e, stack) {
      log(
        'Error stopping $name: $e',
        name: 'Navigation',
        error: e,
        stackTrace: stack,
      );
    }
  }

  @override
  bool get isListening => _subscription != null;
}

