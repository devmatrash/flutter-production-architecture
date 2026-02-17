/// Navigation event types tracked by the observability system
enum NavigationEventType {
  /// New screen pushed on top (back button returns to previous)
  push('push'),

  /// User navigated back or route was removed
  pop('pop'),

  /// Current route replaced with new one (previous removed from stack)
  replace('replace'),

  /// Initial app route on launch (no 'from' route)
  initial('initial'),

  /// Tab switched in TabBar or BottomNavigationBar
  tabChange('tab_change');

  const NavigationEventType(this.value);
  final String value;

  /// Parse string to enum type (throws ArgumentError if invalid)
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

