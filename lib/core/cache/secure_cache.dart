import 'package:flutter_production_architecture/core/cache/cache_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/*
 * SecureCache - Flutter Secure Storage implementation
 *
 * Uses flutter_secure_storage for sensitive data like tokens, passwords,
 * and personal information. Data is encrypted and stored in system keychain.
 */
class SecureCache implements CacheStorage {
  final FlutterSecureStorage _storage;

  SecureCache(this._storage);

  @override
  Future<void> set<T>(String key, T value) async {
    final serialized = CacheSerializer.serialize<T>(value);
    await _storage.write(key: key, value: serialized);
  }

  @override
  Future<T?> get<T>(String key) async {
    final raw = await _storage.read(key: key);
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
    final value = await _storage.read(key: key);
    return value != null;
  }

  @override
  Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> clear() async {
    await _storage.deleteAll();
  }

  @override
  Future<List<String>> keys() async {
    final all = await _storage.readAll();
    return all.keys.toList();
  }

  @override
  Future<int> size() async {
    final all = await _storage.readAll();
    return all.length;
  }
}
