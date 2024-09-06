import 'package:go_router/go_router.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/ui/views/auth_page/auth_page.dart';
import 'package:unn_mobile/ui/views/main_page/main_page.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';

final mainRouter = GoRouter(
  initialLocation: MainPageRouting.navbarRoutes[0].pageRoute,
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainPage(
        child: child,
      ),
      routes: [
        for (var route in MainPageRouting.navbarRoutes)
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
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const AuthPage(),
    ),
  ],
  redirect: (context, state) {
    final authorizationService =
        Injector.appInstance.get<AuthorizationService>();
    final authDataProvider = Injector.appInstance.get<AuthDataProvider>();
    if (!authorizationService.isAuthorised &&
        !authDataProvider.isContainedSync()) {
      return '/auth';
    }
    if (state.uri.path == '/') {
      return '/feed';
    }
    return null;
  },
);
