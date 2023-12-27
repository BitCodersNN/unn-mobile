import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/views/auth_page/auth_page.dart';
import 'package:unn_mobile/ui/views/loading_page/loading_page.dart';
import 'package:unn_mobile/ui/views/main_page/main_page.dart';

class Routes {
  static const String mainPagePrefix = "main/";
  static const String authPage = "auth";
  static const String loadingPage = "loading";
}

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name == Routes.authPage) {
      return createCustomRoute(const AuthPage());
    } else if (settings.name == Routes.loadingPage) {
      return createCustomRoute(const LoadingPage());
    } else if (settings.name!.startsWith(Routes.mainPagePrefix)) {
      return createCustomRoute(
        MainPage(
          subroute: settings.name!.substring(Routes.mainPagePrefix.length),
        ),
      );
    } else {
      return createCustomRoute(
        Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        ),
      );
    }
  }

  static Route<dynamic> createCustomRoute(page,
      {duration = const Duration(milliseconds: 0)}) {
    return PageRouteBuilder(
      transitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          child,
    );
  }
}
