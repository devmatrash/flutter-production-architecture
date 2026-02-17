import 'package:flutter_production_architecture/core/navigation/domain/entities/route_info.dart';
import 'package:flutter_production_architecture/core/navigation/domain/enums/navigation_event_type.dart';

/// Immutable navigation event entity (domain model)
///
/// Represents a single navigation action in the application.
/// Contains platform-agnostic data suitable for analytics, logging, and tracking.
///
/// This entity follows Clean Architecture principles:
/// - No dependencies on routing libraries (auto_route, go_router)
/// - No dependencies on analytics platforms (Firebase, Mixpanel)
/// - Immutable and testable
/// - Self-contained with all necessary context
///
/// Example:
/// ```dart
/// final event = NavigationEvent(
///   type: NavigationEventType.push,
///   from: RouteInfo(name: 'Home', path: '/home'),
///   to: RouteInfo(name: 'Profile', path: '/profile'),
///   timestamp: DateTime.now(),
/// );
/// ```
class NavigationEvent {
  /// Type of navigation action (push, pop, replace, etc.)
  final NavigationEventType type;

  /// Source route (null for initial route or app launch)
  ///
  /// The route the user is navigating FROM.
  /// Will be null for:
  /// - Initial app route (type = NavigationEventType.initial)
  /// - First navigation after app start
  final RouteInfo? from;

  /// Destination route
  ///
  /// The route the user is navigating TO.
  /// This is always present.
  final RouteInfo to;

  /// Route arguments/parameters passed during navigation
  ///
  /// Contains shallow key-value pairs extracted from route arguments.
  /// Sensitive data may be sanitized before storage.
  ///
  /// Example: {'userId': '123', 'mode': 'edit'}
  ///
  /// Note: This is nullable - not all routes have arguments.
  final Map<String, dynamic>? arguments;

  /// When the navigation occurred
  ///
  /// Timestamp captured at the moment of navigation.
  /// Useful for:
  /// - Chronological event ordering
  /// - Time-on-screen calculations
  /// - Performance analysis
  final DateTime timestamp;

  /// Optional session identifier for tracking user sessions
  ///
  /// Reserved for future use (Phase 4: Session Tracking).
  /// Currently nullable - will be populated when session management is implemented.
  ///
  /// Example: 'session_abc123_1234567890'
  final String? sessionId;

  const NavigationEvent({
    required this.type,
    this.from,
    required this.to,
    this.arguments,
    required this.timestamp,
    this.sessionId,
  });

  /// Create a copy with modified fields
  ///
  /// Useful for sanitizing arguments or adding session IDs retroactively.
  NavigationEvent copyWith({
    NavigationEventType? type,
    RouteInfo? from,
    RouteInfo? to,
    Map<String, dynamic>? arguments,
    DateTime? timestamp,
    String? sessionId,
  }) {
    return NavigationEvent(
      type: type ?? this.type,
      from: from ?? this.from,
      to: to ?? this.to,
      arguments: arguments ?? this.arguments,
      timestamp: timestamp ?? this.timestamp,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  /// Check if this is a forward navigation (push, replace)
  bool get isForwardNavigation =>
      type == NavigationEventType.push ||
      type == NavigationEventType.replace ||
      type == NavigationEventType.initial;

  /// Check if this is a backward navigation (pop)
  bool get isBackwardNavigation => type == NavigationEventType.pop;

  /// Check if this is a lateral navigation (tab change)
  bool get isLateralNavigation => type == NavigationEventType.tabChange;

  /// Check if this is the initial app route
  bool get isInitialRoute => type == NavigationEventType.initial;

  /// Get a human-readable description of the navigation
  ///
  /// Example: "push: Home → Profile"
  String get description {
    final fromName = from?.name ?? 'App Start';
    return '${type.value}: $fromName → ${to.name}';
  }

  @override
  String toString() => 'NavigationEvent($description at ${timestamp.toIso8601String()})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationEvent &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          from == other.from &&
          to == other.to &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      type.hashCode ^ from.hashCode ^ to.hashCode ^ timestamp.hashCode;
}

