// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/misc/tab_bar_preferences.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar_context_menu.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar_customization_sheet.dart';

class MainPageNavigationBar extends StatelessWidget {
  final ValueChanged<MainPageRouteData>? onDestinationSelected;
  final List<MainPageRouteData> routes;

  static const navbarHeight = 60.0;

  const MainPageNavigationBar({
    required this.routes,
    super.key,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<List<String>>(
      valueListenable: AppSettings.tabBarPaths,
      builder: (context, savedPaths, _) {
        final paths = TabBarPreferences.normalize(
          savedPaths,
          allowed: routes.map((route) => route.pagePath),
        );
        final visible = paths
            .map((path) => routes.firstWhere((route) => route.pagePath == path))
            .toList();
        return MediaQuery.withNoTextScaling(
          child: CupertinoTabBar(
            height: navbarHeight,
            backgroundColor: theme.colorScheme.surface,
            activeColor: theme.colorScheme.primary,
            inactiveColor: theme.colorScheme.onSurfaceVariant,
            iconSize: 24,
            currentIndex: getSelectedBarIndex(context, paths),
            onTap: (index) => onDestinationSelected?.call(visible[index]),
            items: [
              for (final route in visible)
                BottomNavigationBarItem(
                  icon: _tabButton(route, route.unselectedIcon, paths),
                  activeIcon: _tabButton(route, route.selectedIcon, paths),
                ),
            ],
          ),
        );
      },
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

  Widget _tabButton(
    MainPageRouteData route,
    IconData icon,
    List<String> paths,
  ) =>
      Builder(
        builder: (context) => RawGestureDetector(
          behavior: HitTestBehavior.opaque,
          gestures: {
            TapGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
              TapGestureRecognizer.new,
              (recognizer) =>
                  recognizer.onTap = () => onDestinationSelected?.call(route),
            ),
            LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                LongPressGestureRecognizer>(
              () => LongPressGestureRecognizer(
                duration: const Duration(milliseconds: 350),
              ),
              (recognizer) => recognizer.onLongPress =
                  () => _showCustomizationMenu(context, route, paths),
            ),
          },
          child: SizedBox.expand(
            child: Center(child: _buildTabContent(icon, route.pageTitle)),
          ),
        ),
      );

  Future<void> _showCustomizationMenu(
    BuildContext context,
    MainPageRouteData route,
    List<String> paths,
  ) async {
    triggerHaptic(HapticIntensity.medium);
    final customize = await showTabBarContextMenu(
      context,
      icon: route.unselectedIcon,
      label: route.pageTitle,
    );
    if (customize != true || !context.mounted) {
      return;
    }
    await showTabBarCustomizationSheet(
      context,
      routes: routes,
      initialPaths: paths,
      selectedPath: route.pagePath,
    );
  }

  static int getSelectedBarIndex(BuildContext context, List<String> paths) {
    final segments = GoRouterState.of(context).uri.pathSegments;
    final drawerIndex = segments.indexOf(drawerRoutePrefix);
    final destinationIndex = drawerIndex < 0 ? 1 : drawerIndex + 1;
    final destination =
        destinationIndex < segments.length ? segments[destinationIndex] : null;
    final index = destination == null ? -1 : paths.indexOf(destination);
    return index < 0 ? paths.indexOf('more') : index;
  }
}
