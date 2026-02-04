import 'dart:developer';

/// Driver types for cache storage backends
enum CacheDriverType {
  memory('memory'),
  sharedPrefs('shared_prefs'),
  secureStorage('secure_storage');

  const CacheDriverType(this.value);
  final String value;

  static CacheDriverType? fromString(String? value) {
    if (value == null) return null;

    try {
      return values.firstWhere((t) => t.value == value);
    } catch (e) {
      throw ArgumentError(
        'Invalid cache driver: "$value". Valid drivers are: ${values.map((t) => t.value).join(", ")}',
      );
    }
  }
}

/// Abstract storage driver interface
abstract class CacheDriver {
  CacheDriverType get type;
  String get name => type.value;
  bool get isAvailable;

  Future<void> set(String key, String value);
  Future<String?> get(String key);
  Future<bool> has(String key);
  Future<void> remove(String key);
  Future<void> clear();
  Future<List<String>> keys();
}

/// In-memory cache driver (always available, non-persistent)
class MemoryDriver extends CacheDriver {
  final Map<String, String> _cache = {};

  @override
  CacheDriverType get type => CacheDriverType.memory;

  @override
  bool get isAvailable => true; // Always available

  @override
  Future<void> set(String key, String value) async {
    _cache[key] = value;
    log('Memory SET: $key', name: 'Cache');
  }

  @override
  Future<String?> get(String key) async {
    final value = _cache[key];
    log('Memory ${value != null ? "HIT" : "MISS"}: $key', name: 'Cache');
    return value;
  }

  @override
  Future<bool> has(String key) async => _cache.containsKey(key);

  @override
  Future<void> remove(String key) async {
    _cache.remove(key);
    log('Memory REMOVE: $key', name: 'Cache');
  }

  @override
  Future<void> clear() async {
    _cache.clear();
    log('Memory CLEAR', name: 'Cache');
  }

  @override
  Future<List<String>> keys() async => _cache.keys.toList();

  int get size => _cache.length;
}

/// SharedPreferences driver for persistent storage
class SharedPrefsDriver extends CacheDriver {
  final dynamic _prefs;

  SharedPrefsDriver(this._prefs);

  @override
  CacheDriverType get type => CacheDriverType.sharedPrefs;

  @override
  bool get isAvailable => _prefs != null;

  @override
  Future<void> set(String key, String value) async {
    if (!isAvailable) throw StateError('SharedPreferences not available');
    await _prefs!.setString(key, value);
    log('SharedPrefs SET: $key', name: 'Cache');
  }

  @override
  Future<String?> get(String key) async {
    if (!isAvailable) return null;
    final value = _prefs!.getString(key);
    log('SharedPrefs ${value != null ? "HIT" : "MISS"}: $key', name: 'Cache');
    return value;
  }

  @override
  Future<bool> has(String key) async {
    if (!isAvailable) return false;
    return _prefs!.containsKey(key);
  }

  @override
  Future<void> remove(String key) async {
    if (!isAvailable) return;
    await _prefs!.remove(key);
    log('SharedPrefs REMOVE: $key', name: 'Cache');
  }

  @override
  Future<void> clear() async {
    if (!isAvailable) return;
    await _prefs!.clear();
    log('SharedPrefs CLEAR', name: 'Cache');
  }

  @override
  Future<List<String>> keys() async {
    if (!isAvailable) return [];
    return _prefs!.getKeys().toList();
  }
}

/// FlutterSecureStorage driver for encrypted storage
class SecureStorageDriver extends CacheDriver {
  final dynamic _storage;

  SecureStorageDriver(this._storage);

  @override
  CacheDriverType get type => CacheDriverType.secureStorage;

  @override
  bool get isAvailable => _storage != null;

  @override
  Future<void> set(String key, String value) async {
    if (!isAvailable) throw StateError('SecureStorage not available');
    await _storage!.write(key: key, value: value);
    log('SecureStorage SET: $key', name: 'Cache');
  }

  @override
  Future<String?> get(String key) async {
    if (!isAvailable) return null;
    final value = await _storage!.read(key: key);
    log('SecureStorage ${value != null ? "HIT" : "MISS"}: $key', name: 'Cache');
    return value;
  }

  @override
  Future<bool> has(String key) async {
    if (!isAvailable) return false;
    return await _storage!.containsKey(key: key);
  }

  @override
  Future<void> remove(String key) async {
    if (!isAvailable) return;
    await _storage!.delete(key: key);
    log('SecureStorage REMOVE: $key', name: 'Cache');
  }

  @override
  Future<void> clear() async {
    if (!isAvailable) return;
    await _storage!.deleteAll();
    log('SecureStorage CLEAR', name: 'Cache');
  }

  @override
  Future<List<String>> keys() async {
    if (!isAvailable) return [];
    final all = await _storage!.readAll();
    return all.keys.toList();
  }
}
