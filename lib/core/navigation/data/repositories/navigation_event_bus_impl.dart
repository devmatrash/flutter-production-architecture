import 'dart:async';
import 'dart:developer';

import 'package:flutter_production_architecture/core/navigation/domain/entities/navigation_event.dart';
import 'package:flutter_production_architecture/core/navigation/domain/repositories/i_navigation_event_bus.dart';

/// Stream-based event bus using broadcast StreamController
class NavigationEventBusImpl implements INavigationEventBus {
  late final StreamController<NavigationEvent> _controller;

  NavigationEventBusImpl() {
    _controller = StreamController<NavigationEvent>.broadcast();
  }

  /// Publish event to subscribers (try-catch handles rare race condition during disposal)
  ///
  /// Note: No synchronization used to avoid locking overhead (~0.001ms per publish).
  /// The race between isClosed check and add() is acceptable and handled gracefully.
  @override
  void publish(NavigationEvent event) {
    if (_controller.isClosed) {
      log('Warning: Attempted to publish to closed event bus', name: 'NavigationEventBus');
      return;
    }

    try {
      _controller.add(event);
    } catch (e, stack) {
      // Expected during app shutdown if dispose() races with publish()
      log('Error publishing navigation event: $e', name: 'NavigationEventBus', error: e, stackTrace: stack);
    }
  }

  @override
  Stream<NavigationEvent> subscribe() {
    if (_controller.isClosed) {
      return const Stream.empty();
    }
    return _controller.stream;
  }

  @override
  bool get hasActiveListeners => !_controller.isClosed && _controller.hasListener;

  @override
  Future<void> dispose() async {
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}
