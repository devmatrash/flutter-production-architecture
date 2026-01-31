import 'package:flutter/material.dart';

class BootstrapDelegates {
  Future<void> beforeRunApp(WidgetsBinding widgetsBinding) async {}

  Future<void> afterRunApp() async {}

  void onAppError(Object error, StackTrace stack) {}
}
