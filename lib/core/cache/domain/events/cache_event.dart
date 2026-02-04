/// Event types for cache operations
enum CacheEventType {
  /// Key was created (first time set)
  created,

  /// Key value was updated (overwritten)
  updated,

  /// Key was removed
  removed,

  /// Key expired due to TTL
  expired,

  /// Cache was cleared
  cleared,
}

/// Event emitted when cache state changes
class CacheEvent {
  /// The cache key that changed
  final String key;

  /// Type of change that occurred
  final CacheEventType type;

  /// New value (for created/updated events)
  final dynamic value;

  /// Previous value (for updated/removed/expired events)
  final dynamic oldValue;

  /// When the event occurred
  final DateTime timestamp;

  const CacheEvent({
    required this.key,
    required this.type,
    this.value,
    this.oldValue,
    required this.timestamp,
  });

  /// Check if this is a creation event
  bool get isCreated => type == CacheEventType.created;

  /// Check if this is an update event
  bool get isUpdated => type == CacheEventType.updated;

  /// Check if this is a removal event
  bool get isRemoved => type == CacheEventType.removed;

  /// Check if this is an expiration event
  bool get isExpired => type == CacheEventType.expired;

  /// Check if this is a clear event
  bool get isCleared => type == CacheEventType.cleared;

  @override
  String toString() =>
      'CacheEvent(key: $key, type: ${type.name}, timestamp: $timestamp)';
}
