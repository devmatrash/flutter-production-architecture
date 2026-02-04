import 'package:flutter_production_architecture/core/cache/domain/events/cache_event.dart';

/// Core cache interface for dependency injection and testing
abstract class ICache {
  Future<void> set<T>(String key, T value, {String? driver, Duration? ttl});
  Future<T?> get<T>(String key, {String? driver});
  Future<bool> has(String key, {String? driver});
  Future<void> remove(String key, {String? driver});
  Future<void> clear({String? driver});
  Future<List<String>> keys({String? driver});
  Future<int> size({String? driver});

  Future<void> setMultiple(
    Map<String, dynamic> items, {
    String? driver,
    Duration? ttl,
  });
  Future<Map<String, T?>> getMultiple<T>(
    List<String> keys, {
    String? driver,
  });
  Future<void> removeMultiple(List<String> keys, {String? driver});

  Future<void> clearAll();
  Future<Map<String, dynamic>> getStats();

  bool get isInitialized;
  String? get defaultDriver;
  Map<String, bool> get driverHealth;

  /// Subscribe to changes for a specific key
  void subscribe(String key, void Function(CacheEvent event) callback);

  /// Unsubscribe from a specific key
  void unsubscribe(String key, void Function(CacheEvent event) callback);

  /// Subscribe to all cache changes
  void subscribeAll(void Function(String key, CacheEvent event) callback);

  /// Unsubscribe from all cache changes
  void unsubscribeAll(void Function(String key, CacheEvent event) callback);
}

/// Secure cache interface
abstract class ISecureCache {
  Future<void> set<T>(String key, T value, {Duration? ttl});
  Future<T?> get<T>(String key);
  Future<bool> has(String key);
  Future<void> remove(String key);
  Future<void> clear();
}
