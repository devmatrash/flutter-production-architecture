import 'package:flutter_production_architecture/core/navigation/domain/repositories/i_navigation_event_bus.dart';

/// Strategy interface for handling navigation events
///
/// Implementations of this interface can perform various actions in response
/// to navigation events, such as:
/// - Logging to console or file
/// - Sending analytics to Firebase, Mixpanel, Amplitude
/// - Recording crash context breadcrumbs (Sentry, Crashlytics)
/// - Tracking route timing for performance analysis
/// - Building user flow diagrams
///
/// The strategy pattern allows multiple listeners to coexist without
/// tight coupling. Each listener is independent and can be enabled/disabled
/// via dependency injection configuration.
///
/// Design Principles:
/// - Each listener handles its own errors (fail independently)
/// - Listeners process events asynchronously (non-blocking)
/// - Listeners can be conditionally registered (dev vs production)
///
/// Example Implementation:
/// ```dart
/// class AnalyticsNavigationListener implements INavigationListener {
///   final FirebaseAnalytics _analytics;
///
///   @override
///   String get name => 'AnalyticsNavigationListener';
///
///   @override
///   void startListening(INavigationEventBus eventBus) {
///     _subscription = eventBus.subscribe().listen(_onEvent);
///   }
///
///   void _onEvent(NavigationEvent event) {
///     _analytics.logScreenView(screenName: event.to.name);
///   }
/// }
/// ```
abstract class INavigationListener {
  /// Human-readable listener name (for debugging and logs)
  ///
  /// Used in log messages to identify which listener is active.
  /// Example: 'LoggingNavigationListener', 'FirebaseAnalyticsListener'
  String get name;

  /// Start listening to navigation events
  ///
  /// Called during service provider registration (app startup).
  /// The listener should:
  /// 1. Subscribe to the event bus stream
  /// 2. Store the subscription for later cancellation
  /// 3. Handle events in the subscription callback
  /// 4. Catch and log any errors internally
  ///
  /// The event bus is injected to maintain dependency inversion -
  /// listeners depend on the abstraction, not the implementation.
  ///
  /// Example:
  /// ```dart
  /// StreamSubscription<NavigationEvent>? _subscription;
  ///
  /// @override
  /// void startListening(INavigationEventBus eventBus) {
  ///   _subscription = eventBus.subscribe().listen(
  ///     _handleEvent,
  ///     onError: _handleError,
  ///   );
  ///   log('$name started', name: 'Navigation');
  /// }
  /// ```
  void startListening(INavigationEventBus eventBus);

  /// Stop listening and clean up resources
  ///
  /// Called during app shutdown or when the listener is no longer needed.
  /// The listener should:
  /// 1. Cancel any active stream subscriptions
  /// 2. Release any held resources
  /// 3. Flush any pending data (if applicable)
  ///
  /// This prevents memory leaks and ensures clean shutdown.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<void> stopListening() async {
  ///   await _subscription?.cancel();
  ///   _subscription = null;
  ///   log('$name stopped', name: 'Navigation');
  /// }
  /// ```
  Future<void> stopListening();

  /// Whether this listener is currently active
  ///
  /// Returns true if the listener is subscribed and processing events.
  /// Used for health checks and debugging.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// bool get isListening => _subscription != null;
  /// ```
  bool get isListening;
}

