import 'package:flutter_production_architecture/core/cache/cache_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
 * RegularCache - SharedPreferences implementation
 *
 * Uses SharedPreferences for non-sensitive data storage.
 * Suitable for user preferences, settings, and general app data.
 */
class RegularCache implements CacheStorage {
  final SharedPreferences _prefs;

  RegularCache(this._prefs);

  @override
  Future<void> set<T>(String key, T value) async {
    final serialized = CacheSerializer.serialize<T>(value);
    await _prefs.setString(key, serialized);
  }

  @override
  Future<T?> get<T>(String key) async {
    final raw = _prefs.getString(key);
    if (raw == null) return null;

    try {
      return CacheSerializer.deserialize<T>(raw);
    } catch (e) {
      // Log error and return null for corrupted data
      return null;
    }
  }

  @override
  Future<bool> has(String key) async {
    return _prefs.containsKey(key);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }

  @override
  Future<List<String>> keys() async {
    return _prefs.getKeys().toList();
  }

  @override
  Future<int> size() async {
    return _prefs.getKeys().length;
  }
}
