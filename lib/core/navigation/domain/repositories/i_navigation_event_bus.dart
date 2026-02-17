import 'package:flutter_production_architecture/core/navigation/domain/entities/navigation_event.dart';

/// Event bus for decoupled publish-subscribe of navigation events
abstract class INavigationEventBus {
  /// Publish event to all subscribers (async, non-blocking)
  void publish(NavigationEvent event);

  /// Subscribe to navigation events via broadcast stream
  Stream<NavigationEvent> subscribe();

  /// Check if any listeners are active (for performance optimization)
  bool get hasActiveListeners;

  /// Close stream and release resources
  Future<void> dispose();
}
