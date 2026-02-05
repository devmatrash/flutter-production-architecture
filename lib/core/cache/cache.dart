/*
 * Cache module - Clean Architecture implementation
 *
 * This is the main entry point for the cache module.
 * It re-exports the public API while maintaining clean architecture.
 */

// Public API (Presentation Layer) - Main facade
export 'presentation/cache_facade.dart' show Cache, CacheSecureProxy;

// Domain Layer (for dependency injection and testing)
export 'domain/repositories/i_cache.dart';
export 'domain/entities/cache_config.dart';
export 'domain/exceptions/cache_exceptions.dart';
export 'domain/events/cache_event.dart';
export 'domain/strategies/cache_driver_strategy.dart';

// Data Layer (for advanced usage and DI setup)
export 'data/repositories/cache_repository_impl.dart';

// Service Provider (for initialization)
export 'di/cache_service_provider.dart';
