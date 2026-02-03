/*
 * CacheConfig - Production cache configuration
 *
 * Provides explicit control over cache behavior without over-engineering.
 */
class CacheConfig {
  /// Enable Time-To-Live functionality (explicit opt-in)
  final bool enableTTL;

  /// Maximum items per driver to prevent memory bloat
  final int maxItemsPerDriver;

  /// Maximum key length for validation (prevents storage issues)
  final int maxKeyLength;

  /// Enable batch operations for performance optimization
  final bool enableBatching;

  /// Log driver fallbacks for operational monitoring
  final bool logFallbacks;

  const CacheConfig({
    this.enableTTL = false, // Explicit opt-in
    this.maxItemsPerDriver = 1000, // Reasonable default
    this.maxKeyLength = 250, // Standard key length limit
    this.enableBatching = true, // Performance optimization
    this.logFallbacks = true, // Operational visibility
  });

  /// Production defaults
  factory CacheConfig.defaults() => const CacheConfig();

  /// Production configuration
  factory CacheConfig.production() => const CacheConfig(
    enableTTL: true,
    maxItemsPerDriver: 2000,
    maxKeyLength: 250,
    // Standard production limit
    enableBatching: true,
    logFallbacks: true,
  );

  /// Development configuration with relaxed limits
  factory CacheConfig.development() => const CacheConfig(
    enableTTL: false,
    maxItemsPerDriver: 100,
    maxKeyLength: 100,
    // Shorter keys for development
    enableBatching: false,
    // Simpler debugging
    logFallbacks: true,
  );

  @override
  String toString() =>
      'CacheConfig(ttl: $enableTTL, maxItems: $maxItemsPerDriver, maxKeyLength: $maxKeyLength)';
}
