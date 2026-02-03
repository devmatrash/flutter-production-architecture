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
}

/// Secure cache interface
abstract class ISecureCache {
  Future<void> set<T>(String key, T value, {Duration? ttl});
  Future<T?> get<T>(String key);
  Future<bool> has(String key);
  Future<void> remove(String key);
  Future<void> clear();
}
