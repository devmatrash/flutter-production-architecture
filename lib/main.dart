import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_production_architecture/handbook_app.dart';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      runApp(HandbookApp());
    },
    (Object error, StackTrace stack) {
      log("Error occurred: $error", stackTrace: stack, name: 'runZonedGuarded');
    },
  );
}
