/// Configuration for argument sanitization in navigation events
class ArgumentSanitizationConfig {
  final bool enabled;
  final List<String> sensitiveKeys;
  final String placeholder;

  /// Pre-computed lowercase Set for O(1) lookups (performance optimization)
  late final Set<String> _sensitiveKeysLowerSet;

  /// Default sensitive key patterns (reusable)
  static const List<String> defaultSensitiveKeys = [
    'token',
    'password',
    'passwd',
    'pwd',
    'secret',
    'apikey',
    'api_key',
    'auth',
    'credential',
    'private',
    'ssn',
    'credit',
    'card',
    'cvv',
  ];

  /// Strict config - secure default with all patterns
  static final strict = ArgumentSanitizationConfig(
    enabled: true,
    sensitiveKeys: defaultSensitiveKeys,
  );

  /// Disabled config - no sanitization (for debugging)
  static final disabled = ArgumentSanitizationConfig(
    enabled: false,
    sensitiveKeys: [],
  );

  /// Default constructor - allows full customization
  ArgumentSanitizationConfig({
    required this.enabled,
    required this.sensitiveKeys,
    this.placeholder = '[REDACTED]',
  }) {
    // Pre-compute lowercase Set for fast lookups
    _sensitiveKeysLowerSet = sensitiveKeys.map((k) => k.toLowerCase()).toSet();
  }

  /// Check if a key matches any sensitive pattern (O(1) average case)
  bool isSensitiveKey(String key) {
    if (!enabled) return false;
    final keyLower = key.toLowerCase();
    // Check if any pattern is contained in the key
    return _sensitiveKeysLowerSet.any((pattern) => keyLower.contains(pattern));
  }
}

