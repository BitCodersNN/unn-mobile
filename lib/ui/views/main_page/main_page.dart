// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/app_open_tracker.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/services/interfaces/birthday/birthday_greeting_service.dart';
import 'package:unn_mobile/ui/birthday/birthday_greeting_host.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/main_page_locations.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar/main_page_navigation_bar.dart';
import 'package:unn_mobile/ui/widgets/dialogs/analytics_confirm_dialog.dart';
import 'package:unn_mobile/ui/widgets/dialogs/changelog_dialog.dart';

class MainPage extends StatefulWidget {
  final StatefulNavigationShell shell;

  const MainPage({required this.shell, super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  bool _startupDialogsComplete = false;

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
      if (mounted) {
        setState(() => _startupDialogsComplete = true);
      }
    });
  }

  bool isRootScreen(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return AppRouter.of(context)
        .configuration
        .tabs
        .any((r) => mainPageTabLocation(r.pagePath) == location);
  }

  @override
  Widget build(BuildContext context) => BirthdayGreetingHost(
        userStorage: Injector.appInstance.get<CurrentUserSyncStorage>(),
        service: Injector.appInstance.get<BirthdayGreetingService>(),
        enabled: _startupDialogsComplete,
        child: Scaffold(
          extendBody: false,
          body: Builder(
            builder: (context) => widget.shell,
          ),
          bottomNavigationBar: OnlineStatusBuilder(
            builder: (context, isOnline) => MainPageNavigationBar(
              routes: AppRouter.of(context).configuration.destinations,
              onDestinationSelected: (route) {
                if (route.isDisabled || (route.onlineOnly && !isOnline)) {
                  return;
                }
                final index =
                    AppRouter.of(context).configuration.tabs.indexWhere(
                          (destination) =>
                              destination.pagePath == route.pagePath,
                        );
                if (index < 0) {
                  AppRouter.of(context)
                      .goToDestination(route.pagePath, initialLocation: true);
                  return;
                }
                final currentIndex = widget.shell.currentIndex;
                if (index == currentIndex && isRootScreen(context)) {
                  route.onReselect?.call(context);
                  return;
                }
                AppRouter.of(context).goToDestination(
                  route.pagePath,
                  initialLocation: index == currentIndex,
                );
              },
            ),
          ),
        ),
      );
}
