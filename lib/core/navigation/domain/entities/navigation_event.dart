import 'package:flutter_production_architecture/core/navigation/domain/entities/route_info.dart';
import 'package:flutter_production_architecture/core/navigation/domain/enums/navigation_event_type.dart';

/// Navigation event capturing route transitions with platform-agnostic data
class NavigationEvent {
  /// Type of navigation (push, pop, replace, initial, tabChange)
  final NavigationEventType type;

  /// Source route (null for initial/app launch)
  final RouteInfo? from;

  /// Destination route (always present)
  final RouteInfo to;

  /// Route arguments (sanitized for sensitive data)
  final Map<String, dynamic>? arguments;

  /// Navigation timestamp for ordering and timing analysis
  final DateTime timestamp;

  /// Optional session ID (reserved for Phase 4: Session Tracking)
  final String? sessionId;

  const NavigationEvent({
    required this.type,
    this.from,
    required this.to,
    this.arguments,
    required this.timestamp,
    this.sessionId,
  });

  /// Create a copy with modified fields (useful for sanitization)
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

  /// Check if navigation is forward (push/replace/initial)
  bool get isForwardNavigation =>
      type == NavigationEventType.push ||
      type == NavigationEventType.replace ||
      type == NavigationEventType.initial;

  /// Check if navigation is backward (pop)
  bool get isBackwardNavigation => type == NavigationEventType.pop;

  /// Check if navigation is lateral (tab change)
  bool get isLateralNavigation => type == NavigationEventType.tabChange;

  /// Check if this is the initial app route
  bool get isInitialRoute => type == NavigationEventType.initial;

  /// Human-readable description (e.g., "push: Home → Profile")
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

