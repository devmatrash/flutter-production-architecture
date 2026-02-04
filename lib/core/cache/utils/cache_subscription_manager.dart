import 'dart:developer';

import 'package:flutter_production_architecture/core/cache/domain/events/cache_event.dart';

/// Callback for key-specific subscriptions
typedef CacheSubscriber = void Function(CacheEvent event);

/// Callback for global subscriptions (all keys)
typedef CacheGlobalSubscriber = void Function(String key, CacheEvent event);

/// Manages cache event subscriptions using Observer pattern
class CacheSubscriptionManager {
  /// Key-specific subscribers
  final Map<String, List<CacheSubscriber>> _keySubscribers = {};

  /// Global subscribers (listen to all keys)
  final List<CacheGlobalSubscriber> _globalSubscribers = [];

  /// Subscribe to changes for a specific key
  void subscribe(String key, CacheSubscriber callback) {
    _keySubscribers.putIfAbsent(key, () => []).add(callback);
  }

  /// Unsubscribe from a specific key
  void unsubscribe(String key, CacheSubscriber callback) {
    _keySubscribers[key]?.remove(callback);

    // Clean up empty lists to prevent memory leaks
    if (_keySubscribers[key]?.isEmpty ?? false) {
      _keySubscribers.remove(key);
    }
  }

  /// Subscribe to all cache changes
  void subscribeAll(CacheGlobalSubscriber callback) {
    _globalSubscribers.add(callback);
  }

  /// Unsubscribe from all cache changes
  void unsubscribeAll(CacheGlobalSubscriber callback) {
    _globalSubscribers.remove(callback);
  }

  /// Check if anyone is listening to this key (performance optimization)
  bool hasSubscribers(String key) =>
      _keySubscribers.containsKey(key) || _globalSubscribers.isNotEmpty;

  /// Notify subscribers of a cache event
  void notify(CacheEvent event) {
    // Skip notification if no one is listening (performance optimization)
    if (!hasSubscribers(event.key)) return;

    // Notify key-specific subscribers
    final keySubscribers = _keySubscribers[event.key];
    if (keySubscribers != null) {
      for (final callback in keySubscribers) {
        try {
          callback(event);
        } catch (e, stackTrace) {
          // Prevent one subscriber error from affecting others
          log(
            'Cache subscriber error for key ${event.key}: $e',
            name: 'CacheSubscriptionManager',
            error: e,
            stackTrace: stackTrace,
          );
        }
      }
    }

    // Notify global subscribers
    for (final callback in _globalSubscribers) {
      try {
        callback(event.key, event);
      } catch (e, stackTrace) {
        // Prevent one subscriber error from affecting others
        log(
          'Cache global subscriber error: $e',
          name: 'CacheSubscriptionManager',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }
  }

  /// Clear all subscriptions (useful for testing or app reset)
  void clear() {
    _keySubscribers.clear();
    _globalSubscribers.clear();
  }

  /// Get number of keys being observed (for debugging)
  int get keySubscriberCount => _keySubscribers.length;

  /// Get number of global subscribers (for debugging)
  int get globalSubscriberCount => _globalSubscribers.length;
}
