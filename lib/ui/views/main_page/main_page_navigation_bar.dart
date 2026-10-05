// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/misc/tab_bar_preferences.dart';
import 'package:unn_mobile/ui/main_page_locations.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar_context_menu.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar_context_menu_session.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar_customization_sheet.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar_gesture_detector.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar_item_content.dart';

class MainPageNavigationBar extends StatefulWidget {
  final ValueChanged<MainPageRouteData>? onDestinationSelected;
  final List<MainPageRouteData> routes;
  final ValueListenable<List<String>>? paths;
  final TabBarPathsSaver savePaths;

  static const navbarHeight = 60.0;

  const MainPageNavigationBar({
    required this.routes,
    super.key,
    this.onDestinationSelected,
    this.paths,
    this.savePaths = AppSettings.updateTabBarPaths,
  });

  @override
  State<MainPageNavigationBar> createState() => _MainPageNavigationBarState();

  static int getSelectedBarIndex(BuildContext context, List<String> paths) {
    final destination = mainPageDestinationPath(GoRouterState.of(context).uri);
    final index = destination == null ? -1 : paths.indexOf(destination);
    return index < 0 ? paths.indexOf(TabBarPreferences.morePath) : index;
  }
}

class _MainPageNavigationBarState extends State<MainPageNavigationBar> {
  final _barKey = GlobalKey();
  TabBarContextMenuSession? _session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<List<String>>(
      valueListenable: widget.paths ?? AppSettings.tabBarPaths,
      builder: (context, savedPaths, _) {
        final routesByPath = {
          for (final route in widget.routes) route.pagePath: route,
        };
        final paths = TabBarPreferences.normalize(
          savedPaths,
          allowed: routesByPath.keys,
        );
        final visible = paths.map((path) => routesByPath[path]!).toList();
        return MediaQuery.withNoTextScaling(
          child: CupertinoTabBar(
            key: _barKey,
            height: MainPageNavigationBar.navbarHeight,
            backgroundColor: theme.colorScheme.surface,
            activeColor: theme.colorScheme.primary,
            inactiveColor: theme.colorScheme.onSurfaceVariant,
            iconSize: 24,
            currentIndex:
                MainPageNavigationBar.getSelectedBarIndex(context, paths),
            onTap: (index) =>
                widget.onDestinationSelected?.call(visible[index]),
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

  Widget _tabButton(
    MainPageRouteData route,
    IconData icon,
    List<String> paths,
  ) =>
      Builder(
        builder: (context) => TabBarGestureDetector(
          onTap: () => widget.onDestinationSelected?.call(route),
          onHoldStart: (pointer) =>
              _showCustomizationMenu(context, route, paths, pointer),
          onHoldMove: (pointer) => _session?.move(pointer),
          onHoldEnd: () => _session?.end(),
          child: SizedBox.expand(
            child: Center(
              child: TabBarItemContent(icon: icon, label: route.pageTitle),
            ),
          ),
        ),
      );

  Future<void> _showCustomizationMenu(
    BuildContext context,
    MainPageRouteData route,
    List<String> paths,
    Offset pointerOrigin,
  ) async {
    if (_session != null) {
      return;
    }
    final overlay = Navigator.of(context, rootNavigator: true)
        .overlay!
        .context
        .findRenderObject()! as RenderBox;
    final anchor = context.findRenderObject()! as RenderBox;
    final bar = _barKey.currentContext!.findRenderObject()! as RenderBox;
    final session = TabBarContextMenuSession(
      paths: paths,
      barRect: bar.localToGlobal(Offset.zero, ancestor: overlay) & bar.size,
      anchor:
          anchor.localToGlobal(Offset.zero, ancestor: overlay) & anchor.size,
      heldPath: route.pagePath,
      selectedPath:
          paths[MainPageNavigationBar.getSelectedBarIndex(context, paths)],
      pointerOrigin: pointerOrigin,
      textDirection: Directionality.of(context),
    );
    _session = session;
    triggerHaptic(HapticIntensity.medium);
    try {
      final result = await showTabBarContextMenu(
        context,
        session: session,
        routes: widget.routes,
      );
      if (result == null) {
        return;
      }
      if (!listEquals(result.paths, paths)) {
        if (!await _saveOrder(result.paths)) {
          return;
        }
      }
      if (!context.mounted) {
        return;
      }
      if (result.destinationPath != null) {
        widget.onDestinationSelected?.call(
          widget.routes.firstWhere(
            (destination) => destination.pagePath == result.destinationPath,
          ),
        );
      }
      if (result.customize) {
        await showTabBarCustomizationSheet(
          context,
          routes: widget.routes,
          selectedPath: session.heldPath,
          initialPaths: widget.paths?.value,
          savePaths: widget.savePaths,
        );
      }
    } finally {
      _session = null;
      session.dispose();
    }
  }

  Future<bool> _saveOrder(List<String> paths) async {
    try {
      await widget.savePaths(paths);
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось сохранить нижнее меню')),
        );
      }
      return false;
    }
  }
}
