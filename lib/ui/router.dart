// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/ui/views/auth_page/auth_page.dart';
import 'package:unn_mobile/ui/views/loading_page/loading_page.dart';
import 'package:unn_mobile/ui/views/main_page/about/about.dart';
import 'package:unn_mobile/ui/views/main_page/donations/donations.dart';
import 'package:unn_mobile/ui/views/main_page/main_page.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';
import 'package:unn_mobile/ui/views/main_page/settings/settings.dart';

const loadingPageRoute = '/';
const mainPageRoute = '/main';
const authPageRoute = '/auth';
const drawerRoutePrefix = 'drawer';

const settingsPath = 'settings';
const aboutPath = 'about';
const supportPath = 'support';

final shellBranchKeys = [
  for (final route in MainPageRouting.navbarRoutes)
    (key: GlobalKey<NavigatorState>(), route: route),
];

final mainPageKey = GlobalKey<MainPageState>();

final mainRouter = GoRouter(
  initialLocation: loadingPageRoute,
  initialExtra: <String, Object>{},
  routes: [
    GoRoute(
      path: loadingPageRoute,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: LoadingPage(),
      ),
    ),
    GoRoute(
      path: authPageRoute,
      name: 'auth',
      builder: (context, state) => const AuthPage(),
      routes: [
        GoRoute(
          path: settingsPath,
          name: 'settings',
          builder: (_, __) => const SettingsScreenView(
            hasAccount: false,
          ),
        ),
        GoRoute(
          path: aboutPath,
          name: 'about',
          builder: (_, __) => const AboutScreenView(),
        ),
        GoRoute(
          path: supportPath,
          name: 'support',
          builder: (_, __) => const DonationsScreenView(),
        ),
      ],
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainPage(
        key: mainPageKey,
        shell: shell,
      ),
      branches: [
        for (final route in shellBranchKeys)
          StatefulShellBranch(
            navigatorKey: route.key,
            routes: [
              GoRoute(
                path: '$mainPageRoute${route.route.pagePath}',
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
  ],
  redirect: (context, state) {
    if (state.uri.path == mainPageRoute) {
      final pageIndex =
          AppSettings.initialPage < MainPageRouting.activeNavbarRoutes.length
              ? AppSettings.initialPage
              : 0;
      return mainPageRoute +
          MainPageRouting.navbarRoutes
              .where((r) => !r.isDisabled)
              .toList()[pageIndex]
              .pagePath;
    }
    return null;
  },
);

List<GoRoute> _buildSubroutes(
  List<MainPageRouteData> routes, {
  String prefix = '',
}) =>
    routes
        .map(
          (route) => GoRoute(
            path: '$prefix${route.pagePath}',
            builder: (context, state) => route.builder(context, state),
            routes: _buildSubroutes(route.subroutes),
          ),
        )
        .toList(growable: false);
