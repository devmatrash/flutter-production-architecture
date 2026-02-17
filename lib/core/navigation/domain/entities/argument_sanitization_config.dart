/// Configuration for argument sanitization in navigation events
class ArgumentSanitizationConfig {
  final bool enabled;
  final List<String> sensitiveKeys;
  final String placeholder;

  const ArgumentSanitizationConfig({
    required this.enabled,
    required this.sensitiveKeys,
    this.placeholder = '[REDACTED]',
  });

  /// Production config - strict sanitization (all patterns)
  factory ArgumentSanitizationConfig.production() {
    return const ArgumentSanitizationConfig(
      enabled: true,
      sensitiveKeys: [
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
      ],
    );
  }

  /// Development config - no sanitization for debugging
  factory ArgumentSanitizationConfig.development() {
    return const ArgumentSanitizationConfig(
      enabled: false,
      sensitiveKeys: [],
    );
  }

  /// Custom config with specific patterns
  factory ArgumentSanitizationConfig.custom({
    required bool enabled,
    required List<String> sensitiveKeys,
    String placeholder = '[REDACTED]',
  }) {
    return ArgumentSanitizationConfig(
      enabled: enabled,
      sensitiveKeys: sensitiveKeys,
      placeholder: placeholder,
    );
  }
}

