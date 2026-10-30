// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/constants/main_page_paths.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/ui/main_page_locations.dart';
import 'package:unn_mobile/ui/main_page_route_configuration.dart';
import 'package:unn_mobile/ui/views/auth_page/auth_page.dart';
import 'package:unn_mobile/ui/views/loading_page/loading_page.dart';
import 'package:unn_mobile/ui/views/main_page/about/about.dart';
import 'package:unn_mobile/ui/views/main_page/donations/donations.dart';
import 'package:unn_mobile/ui/views/main_page/main_page.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_route_data.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';
import 'package:unn_mobile/ui/views/main_page/settings/settings.dart';

class AppRouter extends ChangeNotifier {
  final ValueListenable<List<String>> _tabPaths;
  final ValueListenable<Type>? _userType;
  final List<MainPageRouteData> _routes;
  final StatefulShellRouteBuilder? _shellBuilder;
  final GlobalKey<StatefulNavigationShellState> _shellKey =
      GlobalKey<StatefulNavigationShellState>();
  final Map<String, ({MainPageRouteData route, StatefulShellBranch branch})>
  _branches = {};
  final Map<String, ({Uri uri, Object? extra})> _locations = {};
  late MainPageRouteConfiguration _configuration;
  late final ValueNotifier<RoutingConfig> _routingConfig;
  late final GoRouter _router;

  AppRouter({
    ValueListenable<List<String>>? tabPaths,
    this._userType,
    List<MainPageRouteData>? routes,
    this._shellBuilder,
    String initialLocation = loadingPageRoute,
  }) : _tabPaths = tabPaths ?? AppSettings.tabBarPaths,
       _routes = List.unmodifiable(routes ?? mainPageRoutes) {
    _configuration = _buildConfiguration();
    _routingConfig = ValueNotifier(_buildRoutingConfig());
    _router = GoRouter.routingConfig(
      routingConfig: _routingConfig,
      initialLocation: initialLocation,
    );
    _router.routerDelegate.addListener(_rememberLocation);
    _tabPaths.addListener(_updateRoutes);
    _userType?.addListener(_updateRoutes);
  }

  static AppRouter of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppRouterScope>()!.notifier!;

  GoRouter get router => _router;
  MainPageRouteConfiguration get configuration => _configuration;

  String locationFor(String path) => _configuration.locationFor(path);

  void goToDestination(String path, {bool initialLocation = false}) {
    if (!_configuration.containsDestination(path)) {
      return;
    }
    final saved = initialLocation ? null : _locations[path];
    if (saved != null) {
      final destination = mainPageDestinationPath(saved.uri);
      if (destination != null &&
          _configuration.containsDestination(destination) &&
          (path != MainPagePaths.more ||
              destination == MainPagePaths.more ||
              !_configuration.paths.contains(destination))) {
        _router.go(
          _configuration.relocate(saved.uri).toString(),
          extra: saved.extra,
        );
        return;
      }
    }
    _router.go(locationFor(path));
  }

  void _rememberLocation() {
    final matches = _router.routerDelegate.currentConfiguration;
    if (matches.isEmpty || matches.isError) {
      return;
    }
    final destination = mainPageDestinationPath(matches.uri);
    if (destination == null) {
      _locations.clear();
      return;
    }
    final location = (uri: matches.uri, extra: matches.extra);
    _locations[destination] = location;
    if (!_configuration.paths.contains(destination) ||
        destination == MainPagePaths.more) {
      _locations[MainPagePaths.more] = location;
    }
  }

  MainPageRouteConfiguration _buildConfiguration() =>
      MainPageRouteConfiguration(
        routes: _routes,
        paths: _tabPaths.value,
        userType: _userType?.value,
      );

  void _updateRoutes() {
    final next = _buildConfiguration();
    if (listEquals(_configuration.paths, next.paths) &&
        listEquals(_configuration.destinations, next.destinations)) {
      return;
    }
    final matches = _router.routerDelegate.currentConfiguration;
    final information = _router.routeInformationProvider.value;
    final uri = information.uri;
    final state = information.state;
    final extra = state is RouteInformationState ? state.extra : matches.extra;
    _configuration = next;
    _locations.removeWhere((path, _) => !next.containsDestination(path));
    _routingConfig.value = _buildRoutingConfig();
    final relocated = next.relocate(uri);
    if (relocated != uri || uri != matches.uri) {
      _router.go(relocated.toString(), extra: extra);
    }
    notifyListeners();
  }

  StatefulShellBranch _branchFor(MainPageRouteData route) {
    final existing = _branches[route.pagePath];
    if (existing != null &&
        existing.route.builder == route.builder &&
        listEquals(existing.route.subroutes, route.subroutes)) {
      return existing.branch;
    }
    final branch = StatefulShellBranch(
      routes: [
        GoRoute(
          path: _configuration.locationFor(route.pagePath),
          name: route.pageTitle,
          pageBuilder: (context, state) => NoTransitionPage(
            key: ValueKey(route.pagePath),
            child: route.builder(context, state),
          ),
          routes: _buildSubroutes(route.subroutes),
        ),
      ],
    );
    _branches[route.pagePath] = (route: route, branch: branch);
    return branch;
  }

  String? _redirect(BuildContext context, GoRouterState state) {
    if (state.uri.path == mainPageRoute) {
      return locationFor(_configuration.paths.first);
    }
    final destination = mainPageDestinationPath(state.uri);
    if (destination == null) {
      return null;
    }
    if (!_configuration.containsDestination(destination)) {
      return locationFor(_configuration.paths.first);
    }
    final canonical = _configuration.relocate(state.uri);
    return canonical == state.uri ? null : canonical.toString();
  }

  RoutingConfig _buildRoutingConfig() => RoutingConfig(
    routes: [
      GoRoute(
        path: loadingPageRoute,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoadingPage()),
      ),
      GoRoute(
        path: authPageRoute,
        name: 'auth',
        builder: (context, state) => const AuthPage(),
        routes: [
          GoRoute(
            path: settingsPath,
            name: 'settings',
            builder: (_, _) => const SettingsScreenView(hasAccount: false),
          ),
          GoRoute(
            path: aboutPath,
            name: 'about',
            builder: (_, _) => const AboutScreenView(),
          ),
          GoRoute(
            path: supportPath,
            name: 'support',
            builder: (_, _) => const DonationsScreenView(),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        key: _shellKey,
        pageBuilder: (context, state, shell) => NoTransitionPage(
          key: const ValueKey('main-shell'),
          child: AppRouterScope(
            router: this,
            child: Builder(
              builder: (context) =>
                  _shellBuilder?.call(context, state, shell) ??
                  MainPage(shell: shell),
            ),
          ),
        ),
        branches: [for (final route in _configuration.tabs) _branchFor(route)],
      ),
    ],
    redirect: _redirect,
  );

  @override
  void dispose() {
    _tabPaths.removeListener(_updateRoutes);
    _userType?.removeListener(_updateRoutes);
    _router.routerDelegate.removeListener(_rememberLocation);
    _router.dispose();
    _routingConfig.dispose();
    super.dispose();
  }
}

class AppRouterScope extends InheritedNotifier<AppRouter> {
  const AppRouterScope({
    required AppRouter router,
    required super.child,
    super.key,
  }) : super(notifier: router);
}

List<GoRoute> _buildSubroutes(List<MainPageRouteData> routes) => [
  for (final route in routes)
    GoRoute(
      path: route.pagePath,
      builder: route.builder,
      routes: _buildSubroutes(route.subroutes),
    ),
];
