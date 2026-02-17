import 'dart:async';
import 'dart:developer';

import 'package:flutter_production_architecture/core/navigation/domain/entities/navigation_event.dart';
import 'package:flutter_production_architecture/core/navigation/domain/repositories/i_navigation_event_bus.dart';

/// Stream-based implementation of the navigation event bus
///
/// This implementation uses a broadcast [StreamController] to deliver
/// navigation events to multiple concurrent subscribers.
///
/// Key Features:
/// - Broadcast stream (multiple listeners supported)
/// - Non-blocking event delivery (fire-and-forget)
/// - Error isolation (listener errors don't affect other listeners)
/// - Memory-safe (proper disposal prevents leaks)
/// - Production-ready logging for monitoring
///
/// Performance Characteristics:
/// - Event publishing: O(1) - immediate return
/// - Memory per event: Transient (not stored)
/// - Listener overhead: Minimal (stream broadcast)
///
/// Example:
/// ```dart
/// final eventBus = NavigationEventBusImpl();
///
/// // Subscribe to events
/// eventBus.subscribe().listen((event) {
///   print('Navigation: ${event.description}');
/// });
///
/// // Publish events
/// eventBus.publish(NavigationEvent(...));
///
/// // Clean up
/// await eventBus.dispose();
/// ```
class NavigationEventBusImpl implements INavigationEventBus {
  late final StreamController<NavigationEvent> _controller;

  /// Create a new event bus instance
  ///
  /// Initializes a broadcast stream controller with lifecycle callbacks
  /// for monitoring subscriber connections.
  NavigationEventBusImpl() {
    _controller = StreamController<NavigationEvent>.broadcast(
      onListen: () {
        log(
          'First subscriber connected to navigation event bus',
          name: 'NavigationEventBus',
        );
      },
      onCancel: () {
        log(
          'Last subscriber disconnected from navigation event bus',
          name: 'NavigationEventBus',
        );
      },
    );

    log('Navigation event bus initialized', name: 'NavigationEventBus');
  }

  @override
  void publish(NavigationEvent event) {
    // Fail-safe: Don't publish if already disposed
    if (_controller.isClosed) {
      log(
        'Warning: Attempted to publish to closed navigation event bus. Event: ${event.description}',
        name: 'NavigationEventBus',
      );
      return;
    }

    try {
      _controller.add(event);

      // Debug logging (can be disabled in production via log level)
      log(
        'Published event: ${event.description}',
        name: 'NavigationEventBus',
        level: 500, // Fine level - for detailed debugging
      );
    } catch (e, stack) {
      // Catch and log errors to prevent crashes in the observer
      // This should rarely happen with broadcast streams
      log(
        'Error publishing navigation event: $e',
        name: 'NavigationEventBus',
        error: e,
        stackTrace: stack,
      );
    }
  }

  @override
  Stream<NavigationEvent> subscribe() {
    if (_controller.isClosed) {
      log(
        'Warning: Attempted to subscribe to closed navigation event bus',
        name: 'NavigationEventBus',
      );
      // Return empty stream instead of throwing
      return const Stream.empty();
    }

    return _controller.stream;
  }

  @override
  bool get hasActiveListeners => !_controller.isClosed && _controller.hasListener;

  @override
  int get subscriberCount {
    // Note: Broadcast streams don't expose exact subscriber count
    // We return 1 if there are any listeners, 0 otherwise
    return hasActiveListeners ? 1 : 0;
  }

  @override
  Future<void> dispose() async {
    if (_controller.isClosed) {
      log(
        'Navigation event bus already disposed',
        name: 'NavigationEventBus',
      );
      return;
    }

    log('Disposing navigation event bus', name: 'NavigationEventBus');

    try {
      await _controller.close();
      log('Navigation event bus disposed successfully', name: 'NavigationEventBus');
    } catch (e, stack) {
      log(
        'Error disposing navigation event bus: $e',
        name: 'NavigationEventBus',
        error: e,
        stackTrace: stack,
      );
    }
  }
}

