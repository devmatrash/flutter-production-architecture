/// Platform-agnostic route metadata
///
/// This entity represents essential information about a route without
/// any dependency on specific routing libraries (auto_route, go_router, etc.).
///
/// Extracted from router-specific types and used throughout the navigation
/// observability system for logging, analytics, and tracking purposes.
class RouteInfo {
  /// Route name (e.g., 'SplashRoute', 'HomeRoute', 'ProfileRoute')
  ///
  /// This is typically the class name of the route in auto_route.
  final String name;

  /// Full route path (e.g., '/splash', '/home', '/user/profile')
  ///
  /// The URL path or route identifier used for navigation.
  final String path;

  /// Query parameters or route parameters
  ///
  /// Contains key-value pairs passed to the route.
  /// Example: {'userId': '123', 'tab': 'settings'}
  ///
  /// Note: Shallow extraction only (top-level keys) for performance.
  final Map<String, dynamic>? parameters;

  /// Optional route title for analytics or UI display
  ///
  /// Human-readable title that may differ from the route name.
  /// Example: 'User Profile' instead of 'ProfileRoute'
  final String? title;

  const RouteInfo({
    required this.name,
    required this.path,
    this.parameters,
    this.title,
  });

  /// Create a copy with modified fields
  RouteInfo copyWith({
    String? name,
    String? path,
    Map<String, dynamic>? parameters,
    String? title,
  }) {
    return RouteInfo(
      name: name ?? this.name,
      path: path ?? this.path,
      parameters: parameters ?? this.parameters,
      title: title ?? this.title,
    );
  }

  @override
  String toString() => 'RouteInfo($name: $path)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          path == other.path;

  @override
  int get hashCode => name.hashCode ^ path.hashCode;
}

