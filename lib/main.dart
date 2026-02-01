import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_production_architecture/core/bootstrap/app_bootstrap.dart';
import 'package:flutter_production_architecture/core/injection/injection_container.dart'
    as inject;
import 'package:flutter_production_architecture/core/providers/app_run_providers.dart';
import 'package:flutter_production_architecture/handbook_app.dart';

AppBootstrap appBootstrap = AppBootstrap();

void main() {
  runZonedGuarded<Future<void>>(() async => await runApplication(), (
    Object error,
    StackTrace stack,
  ) {
    appBootstrap.onAppError(error, stack);
  });
}

/*
 * This method will handle the running app using AppRunTasks Class
 * In this method you will override the app run tasks (before ans after)
 */
Future<void> runApplication() async {
  // Initialize the widgets binding
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize appRunProviders
  await inject.init(appRunProviders);
  // Run the app before
  await appBootstrap.beforeRunApp(WidgetsBinding.instance);
  // Run the app
  runApp(HandbookApp());
  // Run the app after
  try {
    await appBootstrap.afterRunApp();
  } catch (error, stack) {
    await appBootstrap.onAppError(error, stack);
  }
}
