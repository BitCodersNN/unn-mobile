import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/views/auth_page/auth_page.dart';
import 'package:unn_mobile/ui/views/loading_page/loading_page.dart';
import 'package:unn_mobile/ui/views/main_page/main_page.dart';

class Routes {
  static const String mainPagePrefix = "main/";
  static const String authPage = "auth";
  static const String loadingPage = "loading";
}

class _CustomPageRoute extends MaterialPageRoute {
  _CustomPageRoute({required super.builder});

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name == Routes.authPage) {
      return _CustomPageRoute(builder: (_) => const AuthPage());
    } else if (settings.name == Routes.loadingPage) {
      return _CustomPageRoute(builder: (_) => const LoadingPage());
    } else if (settings.name!.startsWith(Routes.mainPagePrefix)) {
      return _CustomPageRoute(
        builder: (_) => MainPage(
          subroute: settings.name!.substring(Routes.mainPagePrefix.length),
        ),
      );
    } else {
      return _CustomPageRoute(builder: (_) {
        return Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        );
      });
    }
  }
}
