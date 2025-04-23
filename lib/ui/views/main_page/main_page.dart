// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:go_router/go_router.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/app_open_tracker.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';
import 'package:unn_mobile/ui/widgets/dialogs/changelog_dialog.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page/main_page_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_drawer.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_navigation_bar.dart';

class MainPage extends StatefulWidget {
  final StatefulNavigationShell shell;

  const MainPage({super.key, required this.shell});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final drawerIdOffset = 10;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await Injector.appInstance
          .get<AppOpenTracker>()
          .isFirstTimeOpenOnVersion()) {
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => const ChangelogDialog(),
          );
        }
      }
    });
  }

  bool isRootScreen(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return MainPageRouting.navbarRoutes.any((r) => r.pageRoute == location);
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<MainPageViewModel>(
      builder: (context, model, _) {
        return Scaffold(
          drawerEdgeDragWidth: MediaQuery.of(context).size.width,
          extendBody: false,
          drawer: isRootScreen(context)
              ? Builder(
                  // Разделяем контекст, иначе в текущем нет Scaffold, а он нам нужен
                  builder: (context) {
                    return MainPageDrawer(
                      model: model,
                      onDestinationSelected: (value) {
                        Scaffold.of(context).closeDrawer();
                        final selectedBarIndex = widget.shell.currentIndex;
                        final currentPageRoute = MainPageRouting
                            .navbarRoutes[selectedBarIndex].pageRoute;
                        final destinationSubroute =
                            model.routes[value].pageRoute;
                        GoRouter.of(context).go(
                          '$currentPageRoute/$drawerRoutePrefix/$destinationSubroute',
                        );
                      },
                    );
                  },
                )
              : null,
          body: Builder(
            builder: (context) {
              return widget.shell;
            },
          ),
          bottomNavigationBar: MainPageNavigationBar(
            model: model,
            onDestinationSelected: (value) {
              final currentRouteIndex = widget.shell.currentIndex;
              if (value == currentRouteIndex) {
                if (isRootScreen(context)) {
                  model.refreshTab(value);
                } else {
                  goToRootScreen(context, currentRouteIndex);
                }
              } else {
                if (GoRouterState.of(context).uri.path.contains('drawer')) {
                  goToRootScreen(context, currentRouteIndex);
                }
                // Без делея эта хрень не работает >:(
                Future.delayed(
                  const Duration(milliseconds: 10),
                  () => widget.shell.goBranch(value),
                );
              }
            },
          ),
        );
      },
      onModelReady: (model) => model.init(),
    );
  }

  void goToRootScreen(BuildContext context, int currentRouteIndex) {
    GoRouter.of(context)
        .go(MainPageRouting.navbarRoutes[currentRouteIndex].pageRoute);
  }
}
