import 'dart:developer';

/// Manages TTL (Time-To-Live) for cache entries
class CacheTTL {
  final Map<String, DateTime> _ttlMap = {};
  final bool enabled;

  CacheTTL({required this.enabled});

  void set(String key, Duration ttl) {
    if (enabled) {
      _ttlMap[key] = DateTime.now().add(ttl);
    }
  }

  bool isExpired(String key) {
    if (!enabled || !_ttlMap.containsKey(key)) return false;

    final expiry = _ttlMap[key]!;
    if (DateTime.now().isAfter(expiry)) {
      _ttlMap.remove(key);
      log('TTL EXPIRED: $key', name: 'Cache');
      return true;
    }
    return false;
  }

  void remove(String key) => _ttlMap.remove(key);

  void removeMultiple(List<String> keys) => keys.forEach(_ttlMap.remove);

  void clear() => _ttlMap.clear();
}
