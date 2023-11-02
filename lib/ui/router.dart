import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/views/auth_page/auth_page.dart';
import 'package:unn_mobile/ui/views/main_page/main_page.dart';

class Routes {
  static const String mainPage = "main";
  static const String authPage = "auth";
}

class _CustomPageRoute extends MaterialPageRoute {
  _CustomPageRoute({required super.builder});

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.mainPage:
        return _CustomPageRoute(builder: (_) => MainPage());
      case Routes.authPage:
        return _CustomPageRoute(builder: (_) => const AuthPage());
      default:
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
