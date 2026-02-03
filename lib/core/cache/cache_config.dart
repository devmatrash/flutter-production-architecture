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

  /// Enable batch operations for performance optimization
  final bool enableBatching;

  /// Log driver fallbacks for operational monitoring
  final bool logFallbacks;

  const CacheConfig({
    this.enableTTL = false, // Explicit opt-in
    this.maxItemsPerDriver = 1000, // Reasonable default
    this.enableBatching = true, // Performance optimization
    this.logFallbacks = true, // Operational visibility
  });

  /// Production defaults
  factory CacheConfig.defaults() => const CacheConfig();

  /// Production configuration
  factory CacheConfig.production() => const CacheConfig(
    enableTTL: true,
    maxItemsPerDriver: 2000,
    enableBatching: true,
    logFallbacks: true,
  );

  @override
  String toString() =>
      'CacheConfig(ttl: $enableTTL, maxItems: $maxItemsPerDriver)';
}
