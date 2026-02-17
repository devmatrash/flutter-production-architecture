/// Types of navigation events that can occur in the application
///
/// This enum represents all possible navigation actions tracked by the system.
/// Used in [NavigationEvent] to distinguish between different route transitions.
enum NavigationEventType {
  /// New route pushed onto the navigation stack
  ///
  /// Triggered when a new screen is displayed on top of the current screen.
  /// The previous route remains in the stack (back button will return to it).
  push('push'),

  /// Route popped from the navigation stack
  ///
  /// Triggered when the user navigates back or a route is programmatically removed.
  /// The previous route becomes visible again.
  pop('pop'),

  /// Route replaced the current route
  ///
  /// Triggered when the current route is replaced with a new one.
  /// The old route is removed from the stack (no back navigation to it).
  replace('replace'),

  /// Initial app route (application launch)
  ///
  /// Triggered when the app first starts and the initial route is displayed.
  /// This event has no 'from' route.
  initial('initial'),

  /// Tab changed in tab-based navigation
  ///
  /// Triggered when switching between tabs in a TabBar or BottomNavigationBar.
  /// Used with auto_route's TabPageRoute.
  tabChange('tab_change');

  const NavigationEventType(this.value);

  /// String representation of the event type
  ///
  /// Useful for serialization to analytics platforms or logs.
  final String value;

  /// Create NavigationEventType from string value
  ///
  /// Throws [ArgumentError] if the value doesn't match any event type.
  static NavigationEventType fromString(String value) {
    try {
      return values.firstWhere((type) => type.value == value);
    } catch (e) {
      throw ArgumentError(
        'Invalid navigation event type: "$value". '
        'Valid types are: ${values.map((t) => t.value).join(", ")}',
      );
    }
  }

  @override
  String toString() => value;
}

