import 'package:flutter_production_architecture/core/cache/di/cache_service_provider.dart';
import 'package:flutter_production_architecture/core/providers/service_provider.dart';

final List<ServiceProvider> appRunProviders = [
  CacheServiceProvider(),
  // Future feature service providers will be added here
];
