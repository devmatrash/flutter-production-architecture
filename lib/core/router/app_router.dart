import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';
import 'route_paths.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // Splash screen - Initial app route
    AutoRoute(
      page: SplashRoute.page,
      path: RoutePaths.splashScreen,
      initial: true,
    ),
  ];
}
