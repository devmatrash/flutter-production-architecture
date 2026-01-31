import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_production_architecture/core/bootstrap/bootstrap_delegates.dart';

class AppBootstrap extends BootstrapDelegates {
  @override
  Future<void> beforeRunApp(WidgetsBinding widgetsBinding) async {
    log('beforeRunApp', name: 'AppBootstrap');
  }

  @override
  Future<void> afterRunApp() async {
    log('afterRunApp', name: 'AppBootstrap');
  }

  @override
  Future<void> onAppError(Object error, StackTrace stack) async {
    log("Error Type : ${error.runtimeType}", name: 'AppBootstrap');
    log('Error: $error', stackTrace: stack, name: 'AppBootstrap');
  }
}
