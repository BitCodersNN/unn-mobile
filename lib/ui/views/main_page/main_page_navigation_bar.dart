// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';

class MainPageNavigationBar extends StatelessWidget {
  final ValueChanged<int>? onDestinationSelected;

  static const navbarHeight = 60.0;

  const MainPageNavigationBar({super.key, this.onDestinationSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MediaQuery.withNoTextScaling(
      child: CupertinoTabBar(
        height: navbarHeight,
        backgroundColor: theme.colorScheme.surface,
        activeColor: theme.colorScheme.primary,
        inactiveColor: theme.colorScheme.onSurfaceVariant,
        iconSize: 24,
        currentIndex: getSelectedBarIndex(context),
        onTap: onDestinationSelected,
        items: [
          for (final route in MainPageRouting.navbarRoutes)
            BottomNavigationBarItem(
              icon: _buildTabContent(route.unselectedIcon, route.pageTitle),
              activeIcon: _buildTabContent(route.selectedIcon, route.pageTitle),
            ),
        ],
      ),
    );
  }

  Widget _buildTabContent(IconData icon, String label) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          SizedBox(
            height: 14,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label, maxLines: 1),
              ),
            ),
          ),
        ],
      );

  static int getSelectedBarIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.contains('/$drawerRoutePrefix/')) {
      return MainPageRouting.moreTabIndex;
    }
    final index = MainPageRouting.navbarRoutes.indexWhere(
      (route) => location.startsWith(mainPageRoute + route.pagePath),
    );
    return index < 0 ? 0 : index;
  }
}
