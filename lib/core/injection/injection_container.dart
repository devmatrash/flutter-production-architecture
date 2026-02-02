import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_production_architecture/core/bootstrap/app_bootstrap.dart';
import 'package:flutter_production_architecture/core/providers/service_provider.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init(List<ServiceProvider> incomingProviders) async {
  log("Initializing dependency injection", name: 'InjectionContainer');

  // Initialize the widgets binding
  WidgetsFlutterBinding.ensureInitialized();
  log("Widgets binding initialized", name: 'InjectionContainer');
  
  // Register core services directly
  log("Registering core services", name: 'InjectionContainer');
  sl.registerSingleton<AppBootstrap>(AppBootstrap());

  // Register feature services via providers
  log("Registering feature services via providers", name: 'InjectionContainer');
  await Future.wait(incomingProviders.map((provider) => provider.register(sl)));

  log("Dependency injection setup completed", name: 'InjectionContainer');
}
