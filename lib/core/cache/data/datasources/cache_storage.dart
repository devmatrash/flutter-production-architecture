import 'dart:convert';

/// Handles type serialization/deserialization for cache storage
class CacheSerializer {
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
        if (value is Map<String, dynamic>) return jsonEncode(value);

        try {
          final json = (value as dynamic).toJson();
          return jsonEncode(json);
        } catch (e) {
          throw UnsupportedError(
            'Type $T must implement toJson() or be a primitive type',
          );
        }
    }
  }

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
          return (T as dynamic).fromJson(json) as T;
        } catch (e) {
          throw UnsupportedError(
            'Type $T must have a fromJson factory constructor',
          );
        }
    }
  }
}
