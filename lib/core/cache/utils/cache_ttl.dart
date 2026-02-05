import 'dart:developer';

/// TTL entry with version for optimistic locking
class TTLEntry {
  final DateTime expiresAt;
  final int version;

  TTLEntry(this.expiresAt, this.version);

  TTLEntry copyWithNewVersion() => TTLEntry(expiresAt, version + 1);
}

/// Manages TTL (Time-To-Live) for cache entries with race condition protection
class CacheTTL {
  final Map<String, TTLEntry> _ttlMap = {};
  final bool enabled;
  int _globalVersion = 0;

  CacheTTL({required this.enabled});

  void set(String key, Duration ttl) {
    if (enabled) {
      _ttlMap[key] = TTLEntry(DateTime.now().add(ttl), _globalVersion++);
    }
  }

  /// Check if expired and return entry for atomic operations
  TTLEntry? getIfExpired(String key) {
    if (!enabled || !_ttlMap.containsKey(key)) return null;

    final entry = _ttlMap[key]!;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      return entry; // Return entry for version check
    }
    return null;
  }

  /// Check if expired (simple check without version tracking)
  bool isExpired(String key) {
    return getIfExpired(key) != null;
  }

  /// Remove only if version matches (atomic operation)
  bool removeIfVersionMatches(String key, int version) {
    final entry = _ttlMap[key];
    if (entry != null && entry.version == version) {
      _ttlMap.remove(key);
      log('TTL EXPIRED (atomic): $key', name: 'Cache');
      return true;
    }
    return false; // Version changed, key was updated
  }

  void remove(String key) => _ttlMap.remove(key);

  void removeMultiple(List<String> keys) => keys.forEach(_ttlMap.remove);

  void clear() => _ttlMap.clear();
}
