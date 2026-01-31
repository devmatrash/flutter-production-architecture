import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_production_architecture/handbook_app.dart';

void main() {
  runZonedGuarded<Future<void>>(() async => await run(), (
    Object error,
    StackTrace stack,
  ) {
    log("Error occurred: $error", stackTrace: stack, name: 'runZonedGuarded');
  });
}

/*
 * This method will handle the running app using AppRunTasks Class
 * In this method you will override the app run tasks (before ans after)
 */
Future<void> run() async {
  // Initialize the widgets binding
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Run the app
  runApp(HandbookApp());
}
