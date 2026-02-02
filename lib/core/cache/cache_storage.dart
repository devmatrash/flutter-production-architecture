import 'dart:convert';

/*
 * CacheStorage - Abstract interface for cache operations
 *
 * This interface defines the contract for cache storage implementations.
 * Uses simple method names (set/get) and supports generic types for
 * type-safe operations.
 */
abstract class CacheStorage {
  /// Store a value with the given key
  Future<void> set<T>(String key, T value);

  /// Retrieve a value by key with type safety
  Future<T?> get<T>(String key);

  /// Check if a key exists in the cache
  Future<bool> has(String key);

  /// Remove a specific key from cache
  Future<void> remove(String key);

  /// Clear all cache data
  Future<void> clear();

  /// Get all cache keys
  Future<List<String>> keys();

  /// Get cache size (number of items)
  Future<int> size();
}

/*
 * CacheSerializer - Handles type serialization/deserialization
 *
 * Automatically converts between Dart types and string storage format.
 * Supports: String, int, double, bool, Map<String, dynamic>, and custom objects.
 */
class CacheSerializer {
  /// Serialize any type to string for storage
  static String serialize<T>(T value) {
    switch (T) {
      case const (String):
        return value as String;
      case const (int):
      case const (double):
      case const (bool):
        return value.toString();
      case const (Map<String, dynamic>):
        return jsonEncode(value);
      default:
        // Handle custom objects with toJson method
        if (value is Map<String, dynamic>) {
          return jsonEncode(value);
        }

        try {
          final json = (value as dynamic).toJson();
          return jsonEncode(json);
        } catch (e) {
          throw UnsupportedError(
            'Type $T must implement toJson() method or be a supported primitive type',
          );
        }
    }
  }

  /// Deserialize string back to original type
  static T deserialize<T>(String raw) {
    switch (T) {
      case const (String):
        return raw as T;
      case const (int):
        return int.parse(raw) as T;
      case const (double):
        return double.parse(raw) as T;
      case const (bool):
        return (raw.toLowerCase() == 'true') as T;
      case const (Map<String, dynamic>):
        return jsonDecode(raw) as T;
      default:
        try {
          final json = jsonDecode(raw) as Map<String, dynamic>;
          // This requires the type to have a fromJson factory constructor
          return (T as dynamic).fromJson(json) as T;
        } catch (e) {
          throw UnsupportedError(
            'Type $T must have a fromJson factory constructor',
          );
        }
    }
  }
}
