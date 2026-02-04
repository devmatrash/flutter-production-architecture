import 'dart:convert';

/// Handles type serialization/deserialization for cache storage
class CacheSerializer {
  static String serialize<T>(T value) {
    // Handle primitives
    if (value is String) return value;
    if (value is int || value is double || value is bool) {
      return value.toString();
    }

    // Handle Map<String, dynamic>
    if (value is Map<String, dynamic>) {
      return jsonEncode(value);
    }

    // Handle List
    if (value is List) {
      return jsonEncode(value);
    }

    // Handle objects with toJson
    try {
      final json = (value as dynamic).toJson();
      return jsonEncode(json);
    } catch (e) {
      throw UnsupportedError(
        'Cannot serialize type $T. '
        'Type must be a primitive (String, int, double, bool), '
        'Map<String, dynamic>, List, or implement toJson() method. '
        'Error: $e',
      );
    }
  }

  static T deserialize<T>(String raw) {
    // Handle primitives
    if (T == String) return raw as T;
    if (T == int) return int.parse(raw) as T;
    if (T == double) return double.parse(raw) as T;
    if (T == bool) return (raw.toLowerCase() == 'true') as T;

    // Try to decode as JSON first
    try {
      final decoded = jsonDecode(raw);

      // If it's already the right type (for Map and List)
      if (decoded is T) return decoded;

      // Handle objects with fromJson
      if (decoded is Map<String, dynamic>) {
        return (T as dynamic).fromJson(decoded) as T;
      }

      return decoded as T;
    } catch (e) {
      throw UnsupportedError(
        'Cannot deserialize type $T. '
        'Type must be a primitive (String, int, double, bool), '
        'Map<String, dynamic>, List, or have a static fromJson(Map<String, dynamic>) factory. '
        'Error: $e',
      );
    }
  }
}
