import 'package:flutter/material.dart';
import 'package:flutter_production_architecture/core/router/app_router.dart';
import 'package:flutter_production_architecture/core/injection/injection_container.dart'
    as inject;
import 'package:flutter_production_architecture/core/navigation/infrastructure/adapters/auto_route_observer_adapter.dart';

class HandbookApp extends StatelessWidget {
  HandbookApp({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Production Architecture',
      debugShowCheckedModeBanner: false,

      // Auto Route Integration with Navigation Observer
      routerDelegate: _appRouter.delegate(
        navigatorObservers: () => [
          inject.sl<AutoRouteObserverAdapter>(),
        ],
      ),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}
