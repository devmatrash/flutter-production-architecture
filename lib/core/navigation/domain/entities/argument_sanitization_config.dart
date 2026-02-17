/// Configuration for argument sanitization in navigation events
class ArgumentSanitizationConfig {
  final bool enabled;
  final List<String> sensitiveKeys;
  final String placeholder;

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
  static const strict = ArgumentSanitizationConfig(
    enabled: true,
    sensitiveKeys: defaultSensitiveKeys,
  );

  /// Disabled config - no sanitization (for debugging)
  static const disabled = ArgumentSanitizationConfig(
    enabled: false,
    sensitiveKeys: [],
  );

  /// Default constructor - allows full customization
  const ArgumentSanitizationConfig({
    required this.enabled,
    required this.sensitiveKeys,
    this.placeholder = '[REDACTED]',
  });
}

