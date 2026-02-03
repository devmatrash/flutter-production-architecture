/// Production cache configuration
class CacheConfig {
  /// Enable Time-To-Live functionality
  final bool enableTTL;

  /// Maximum key length for validation
  final int maxKeyLength;

  /// Log driver fallbacks for operational monitoring
  final bool logFallbacks;

  const CacheConfig({
    this.enableTTL = true,
    this.maxKeyLength = 250,
    this.logFallbacks = true,
  });

  /// Default production configuration
  factory CacheConfig.defaults() => const CacheConfig();

  @override
  String toString() =>
      'CacheConfig(ttl: $enableTTL, maxKeyLength: $maxKeyLength, logFallbacks: $logFallbacks)';
}
