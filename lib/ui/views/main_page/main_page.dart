// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/app_open_tracker.dart';
import 'package:unn_mobile/core/viewmodels/main_page/main_page_view_model.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_navigation_bar.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';
import 'package:unn_mobile/ui/widgets/dialogs/analytics_confirm_dialog.dart';
import 'package:unn_mobile/ui/widgets/dialogs/changelog_dialog.dart';

class MainPage extends StatefulWidget {
  final StatefulNavigationShell shell;

  const MainPage({required this.shell, super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await Injector.appInstance
          .get<AppOpenTracker>()
          .isFirstTimeOpenOnVersion()) {
        if (mounted) {
          await showAnalyticsConfirmation(context);
        }
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
    return MainPageRouting.navbarRoutes
        .any((r) => mainPageRoute + r.pagePath == location);
  }

  @override
  Widget build(BuildContext context) => BaseView<MainPageViewModel>(
        builder: (context, model, _) => Scaffold(
          extendBody: false,
          body: Builder(
            builder: (context) => widget.shell,
          ),
          bottomNavigationBar: MainPageNavigationBar(
            onDestinationSelected: (value) {
              final currentRouteIndex = widget.shell.currentIndex;
              if (value == currentRouteIndex && isRootScreen(context)) {
                if (value != MainPageRouting.moreTabIndex) {
                  model.refreshTab(value);
                }
                return;
              }
              widget.shell.goBranch(
                value,
                initialLocation: value == currentRouteIndex,
              );
            },
          ),
        ),
        onModelReady: (model) => model.init(),
      );
}
