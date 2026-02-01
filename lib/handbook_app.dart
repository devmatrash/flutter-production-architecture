import 'package:flutter/material.dart';
import 'package:flutter_production_architecture/core/router/app_router.dart';

class HandbookApp extends StatelessWidget {
  HandbookApp({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Production Architecture',
      debugShowCheckedModeBanner: false,

      // Auto Route Integration
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}
