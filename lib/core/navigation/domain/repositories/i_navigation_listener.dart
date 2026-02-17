import 'package:flutter_production_architecture/core/navigation/domain/repositories/i_navigation_event_bus.dart';

/// Strategy interface for handling navigation events (logging, analytics, etc.)
abstract class INavigationListener {
  /// Listener name for debugging
  String get name;

  /// Start listening to events from the bus
  void startListening(INavigationEventBus eventBus);

  /// Stop listening and cleanup resources
  Future<void> stopListening();

  /// Check if currently active
  bool get isListening;
}
