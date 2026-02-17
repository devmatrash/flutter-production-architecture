import 'package:flutter_production_architecture/core/navigation/domain/entities/navigation_event.dart';

/// Event bus interface for publishing and subscribing to navigation events
///
/// This interface decouples event producers (route observers) from
/// event consumers (listeners, analytics, logging systems).
///
/// The event bus uses a publish-subscribe pattern with streams for
/// asynchronous, non-blocking event delivery.
///
/// Design Benefits:
/// - Multiple listeners can subscribe without knowing about each other
/// - Adding new listeners doesn't require modifying the observer
/// - Listeners process events asynchronously (no navigation blocking)
/// - Error in one listener doesn't affect others
///
/// Example Usage:
/// ```dart
/// // Producer (in observer)
/// eventBus.publish(NavigationEvent(...));
///
/// // Consumer (in listener)
/// eventBus.subscribe().listen((event) {
///   log('Navigation: ${event.description}');
/// });
/// ```
abstract class INavigationEventBus {
  /// Publish a navigation event to all subscribers
  ///
  /// This is called by the route observer adapter whenever a navigation
  /// action occurs. The event is broadcast to all active subscribers.
  ///
  /// Events are delivered asynchronously - this method returns immediately
  /// without waiting for listeners to process the event.
  ///
  /// If the event bus is disposed, this method will log a warning and
  /// ignore the event (fail-safe behavior).
  void publish(NavigationEvent event);

  /// Subscribe to navigation events
  ///
  /// Returns a broadcast stream that emits [NavigationEvent]s as they occur.
  /// Multiple subscribers can listen to the same stream.
  ///
  /// Subscribers are responsible for:
  /// - Handling their own errors (try-catch in listen callback)
  /// - Canceling subscriptions when no longer needed (prevent memory leaks)
  /// - Processing events asynchronously to avoid blocking
  ///
  /// Example:
  /// ```dart
  /// final subscription = eventBus.subscribe().listen(
  ///   (event) => handleEvent(event),
  ///   onError: (error) => log('Error: $error'),
  /// );
  ///
  /// // Later, when done listening:
  /// await subscription.cancel();
  /// ```
  Stream<NavigationEvent> subscribe();

  /// Check if there are active listeners subscribed to the event bus
  ///
  /// Used for performance optimization - allows the observer to skip
  /// expensive event construction if no one is listening.
  ///
  /// Example:
  /// ```dart
  /// if (eventBus.hasActiveListeners) {
  ///   // Only extract arguments if someone will receive them
  ///   final args = _extractArguments(route);
  ///   eventBus.publish(event.copyWith(arguments: args));
  /// }
  /// ```
  bool get hasActiveListeners;

  /// Number of active subscriptions (for debugging and monitoring)
  ///
  /// Note: With broadcast streams, this may not reflect the exact count
  /// of listeners, but indicates whether any are active.
  int get subscriberCount;

  /// Dispose of resources and close the event stream
  ///
  /// Call this during app shutdown or when the event bus is no longer needed.
  /// After disposal:
  /// - No new events can be published
  /// - All subscribers are disconnected
  /// - Stream is closed
  ///
  /// This prevents memory leaks and ensures clean shutdown.
  Future<void> dispose();
}

