import 'dart:developer';

import 'package:flutter_production_architecture/core/providers/service_provider.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init(List<ServiceProvider> incomingProviders) async {
  log("init providers", name: 'InjectionContainer');
  await Future.wait(incomingProviders.map((provider) => provider.register(sl)));
}
