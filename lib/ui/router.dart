import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/ui/views/auth_page/auth_page.dart';
import 'package:unn_mobile/ui/views/loading_page/loading_page.dart';
import 'package:unn_mobile/ui/views/main_page/main_page.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';

const loadingPageRoute = '/loading';
const mainPageRoute = '/';
const authPageRoute = '/auth';

final mainRouter = GoRouter(
  initialLocation: loadingPageRoute,
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainPage(
        child: child,
      ),
      routes: [
        for (final route in MainPageRouting.navbarRoutes)
          GoRoute(
            path: route.pageRoute,
            name: route.pageTitle,
            pageBuilder: (context, state) =>
                NoTransitionPage(child: route.builder(context)),
            routes: [
              for (final subroute in MainPageRouting.drawerRoutes)
                GoRoute(
                  path: subroute.pageRoute,
                  builder: (context, state) => subroute.builder(context),
                ),
              for (final subroute in route.subroutes)
                GoRoute(
                  path: subroute.pageRoute,
                  builder: (context, state) => subroute.builder(context),
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
      return MainPageRouting.navbarRoutes[pageIndex].pageRoute;
    }
    return null;
  },
);
