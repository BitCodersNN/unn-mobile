// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/viewmodels/main_page/main_page_view_model.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';

class MainPageNavigationBar extends StatelessWidget {
  final void Function(int)? onDestinationSelected;
  final MainPageViewModel model;

  static const navbarHeight = 60.0;
  const MainPageNavigationBar({
    required this.model,
    super.key,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 0.3,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
          NavigationBar(
            destinations: _getNavbarDestinations(
              model,
              context,
            ),
            height: navbarHeight,
            backgroundColor: Colors.transparent,
            indicatorColor: Colors.transparent,
            animationDuration: Duration.zero,
            selectedIndex: getSelectedBarIndex(context),
            onDestinationSelected: onDestinationSelected,
          ),
        ],
      );

  static int getSelectedBarIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    return MainPageRouting.navbarRoutes
        .indexWhere((route) => location.startsWith(route.pageRoute));
  }

  List<Widget> _getNavbarDestinations(
    MainPageViewModel model,
    BuildContext context,
  ) {
    final routes = MainPageRouting.navbarRoutes;
    final destinations = [
      for (final route in routes)
        NavigationDestination(
          icon: Icon(route.unselectedIcon),
          selectedIcon: Icon(
            route.selectedIcon,
            color: Theme.of(context).primaryColor,
          ),
          label: route.pageTitle,
          enabled: !route.isDisabled,
        ),
    ];
    return destinations;
  }
}
