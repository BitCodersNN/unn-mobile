import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/ui/views/auth_page/auth_page.dart';
import 'package:unn_mobile/ui/views/loading_page/loading_page.dart';
import 'package:unn_mobile/ui/views/main_page/main_page.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';

const loadingPageRoute = '/loading';
const mainPageRoute = '/';
const authPageRoute = '/auth';
const drawerRoutePrefix = 'drawer';

final shellBranchKeys = //
    MainPageRouting.navbarRoutes
        .map((route) => (key: GlobalKey<NavigatorState>(), route: route))
        .toList();

final mainRouter = GoRouter(
  initialLocation: loadingPageRoute,
  initialExtra: <String, Object>{},
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainPage(
        shell: shell,
      ),
      branches: [
        for (final route in shellBranchKeys)
          StatefulShellBranch(
            navigatorKey: route.key,
            routes: [
              GoRoute(
                path: route.route.pageRoute,
                name: route.route.pageTitle,
                pageBuilder: (context, state) => NoTransitionPage(
                  child: route.route.builder(context, state),
                ),
                routes: [
                  ..._buildSubroutes(
                    MainPageRouting.drawerRoutes,
                    prefix: '$drawerRoutePrefix/',
                  ),
                  ..._buildSubroutes(route.route.subroutes),
                ],
              ),
            ],
          ),
      ],
    ),
    GoRoute(
      path: authPageRoute,
      name: 'auth',
      builder: (context, state) => const AuthPage(),
    ),
    GoRoute(
      path: loadingPageRoute,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: LoadingPage(),
      ),
    ),
  ],
  redirect: (context, state) {
    if (state.uri.path == mainPageRoute) {
      final pageIndex =
          AppSettings.initialPage < MainPageRouting.activeNavbarRoutes.length
              ? AppSettings.initialPage
              : 0;
      return MainPageRouting.navbarRoutes
          .where((r) => !r.isDisabled)
          .toList()[pageIndex]
          .pageRoute;
    }
    return null;
  },
);

List<GoRoute> _buildSubroutes(
  List<MainPageRouteData> routes, {
  String prefix = '',
}) {
  return routes
      .map(
        (route) => GoRoute(
          path: '$prefix${route.pageRoute}',
          builder: (context, state) => route.builder(context, state),
          routes: _buildSubroutes(route.subroutes),
        ),
      )
      .toList(growable: false);
}
