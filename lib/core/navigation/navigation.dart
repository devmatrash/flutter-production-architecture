/*
 * Navigation observability module - Clean Architecture implementation
 *
 * This module tracks navigation events and publishes them to analytics/logging systems.
 * It provides a decoupled, event-driven architecture for monitoring user navigation flows.
 *
 * Architecture:
 * - Domain Layer: Platform-agnostic entities and interfaces
 * - Data Layer: Event bus implementation using streams
 * - Infrastructure Layer: Router adapters and listener strategies
 *
 * Key Features:
 * - Auto-route integration with zero coupling in domain layer
 * - Event bus pattern for multiple concurrent listeners
 * - Strategy pattern for extensible listener implementations
 * - Performance optimized (< 5ms overhead per navigation)
 * - Privacy-first (argument sanitization)
 *
 * Usage:
 * This module is automatically initialized via NavigationServiceProvider.
 * No manual setup required in features - just navigate normally.
 */

// Domain Layer - Entities and Interfaces (for DI and testing)
export 'domain/entities/navigation_event.dart';
export 'domain/entities/route_info.dart';
export 'domain/enums/navigation_event_type.dart';
export 'domain/repositories/i_navigation_event_bus.dart';
export 'domain/repositories/i_navigation_listener.dart';

// Data Layer - Implementation (for advanced usage)
export 'data/repositories/navigation_event_bus_impl.dart';

// Infrastructure Layer - Adapters and Listeners (for DI setup)
export 'infrastructure/adapters/auto_route_observer_adapter.dart';
export 'infrastructure/listeners/logging_navigation_listener.dart';

// Service Provider (for initialization)
export 'di/navigation_service_provider.dart';

