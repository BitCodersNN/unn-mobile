// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unn_mobile/core/constants/main_page_paths.dart';
import 'package:unn_mobile/core/misc/app_theme_controller.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/common/app_theme_mode.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_widget/schedule_widget_platform.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_widget/schedule_widget_service.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/schedule/schedule_screen_view_model.dart';
import 'package:unn_mobile/ui/home_widget/schedule_widget_binding.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/theme/app_theme.dart';

class UnnMobile extends StatefulWidget {
  final AppThemeController themeController;
  final MainPageRoutesViewModelsFactory routesViewModelsFactory;
  final CurrentUserSyncStorage currentUserStorage;
  final ScheduleWidgetPlatform scheduleWidgetPlatform;
  final ScheduleWidgetService scheduleWidgetService;

  const UnnMobile({
    required this.themeController,
    required this.routesViewModelsFactory,
    required this.currentUserStorage,
    required this.scheduleWidgetPlatform,
    required this.scheduleWidgetService,
    super.key,
  });

  @override
  State<UnnMobile> createState() => _UnnMobileState();
}

class _UnnMobileState extends State<UnnMobile> {
  late final MainPageRoutesViewModelsFactory _routesViewModelsFactory =
      widget.routesViewModelsFactory;
  late final Future<bool> _widgetLaunch = widget.scheduleWidgetPlatform
      .consumeLaunch();
  late final AppRouter _router = AppRouter(
    userType: widget.currentUserStorage,
    initialDestination: _widgetLaunch.then(
      (openSchedule) => openSchedule ? MainPagePaths.schedule : null,
    ),
  );

  late final ScheduleWidgetBinding _scheduleWidget;

  @override
  void initState() {
    super.initState();
    _scheduleWidget = ScheduleWidgetBinding(
      widget.scheduleWidgetService,
      widget.scheduleWidgetPlatform,
      widget.currentUserStorage,
      _router,
      _openPersonalSchedule,
    )..start(initialLaunch: _widgetLaunch);
  }

  void _openPersonalSchedule() {
    final model = _routesViewModelsFactory.getCached<ScheduleScreenViewModel>();
    if (model == null) {
      return;
    }
    model.selectedUser = model.sortedUserTypeList.first;
    model.selectWeek(0);
    final tab = model.currentTab;
    if (tab != null) {
      tab.triggerScrollToToday = true;
      unawaited(tab.clearSearch());
    }
  }

  @override
  void dispose() {
    _scheduleWidget.dispose();
    _router.dispose();
    _routesViewModelsFactory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Provider<MainPageRoutesViewModelsFactory>.value(
        value: _routesViewModelsFactory,
        child: ListenableBuilder(
          listenable: widget.themeController,
          builder: (context, _) => MaterialApp.router(
            routerConfig: _router.router,
            theme: AppTheme.lightThemeFor(widget.themeController.lightTheme),
            darkTheme: AppTheme.darkThemeFor(widget.themeController.darkTheme),
            themeMode: switch (widget.themeController.mode) {
              AppThemeMode.system => ThemeMode.system,
              AppThemeMode.light => ThemeMode.light,
              AppThemeMode.dark => ThemeMode.dark,
            },
            themeAnimationDuration: const Duration(milliseconds: 200),
          ),
        ),
      );
}
