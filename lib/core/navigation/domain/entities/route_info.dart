/// Platform-agnostic route metadata (no dependency on auto_route/go_router)
class RouteInfo {
  /// Route name (e.g., 'SplashRoute', 'HomeRoute')
  final String name;

  /// Full route path (e.g., '/splash', '/home', '/user/profile')
  final String path;

  /// Route parameters (shallow extraction for performance)
  final Map<String, dynamic>? parameters;

  /// Optional human-readable title for analytics
  final String? title;

  const RouteInfo({
    required this.name,
    required this.path,
    this.parameters,
    this.title,
  });

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

