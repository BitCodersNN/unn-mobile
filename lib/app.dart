// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unn_mobile/core/constants/main_page_paths.dart';
import 'package:unn_mobile/core/misc/schedule_activity/schedule_activity_platform.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/services/interfaces/common/app_theme_controller.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/palette_link_platform.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_widget/schedule_widget_platform.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_widget/schedule_widget_service.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/schedule/schedule_screen_view_model.dart';
import 'package:unn_mobile/ui/home_widget/schedule_appearance.dart';
import 'package:unn_mobile/ui/home_widget/schedule_widget_binding.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/theme/app_theme.dart';
import 'package:unn_mobile/ui/theme/palette_link_binding.dart';

class UnnMobile extends StatefulWidget {
  final AppThemeController themeController;
  final MainPageRoutesViewModelsFactory routesViewModelsFactory;
  final CurrentUserSyncStorage currentUserStorage;
  final ScheduleWidgetPlatform scheduleWidgetPlatform;
  final ScheduleWidgetService scheduleWidgetService;
  final ScheduleActivityPlatform scheduleActivityPlatform;
  final PaletteLinkPlatform paletteLinkPlatform;
  final LoggerService loggerService;

  const UnnMobile({
    required this.themeController,
    required this.routesViewModelsFactory,
    required this.currentUserStorage,
    required this.scheduleWidgetPlatform,
    required this.scheduleWidgetService,
    required this.scheduleActivityPlatform,
    required this.paletteLinkPlatform,
    required this.loggerService,
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
  late final PaletteLinkBinding _paletteLink;

  @override
  void initState() {
    super.initState();
    _scheduleWidget = ScheduleWidgetBinding(
      widget.scheduleWidgetService,
      widget.scheduleWidgetPlatform,
      widget.currentUserStorage,
      _router,
      _openPersonalSchedule,
      widget.scheduleActivityPlatform,
    )..start(initialLaunch: _widgetLaunch);
    _paletteLink = PaletteLinkBinding(
      widget.paletteLinkPlatform,
      widget.themeController,
      _router,
      widget.loggerService,
    )..start();
    widget.themeController.addListener(_syncScheduleAppearance);
    _syncScheduleAppearance();
  }

  void _syncScheduleAppearance() => unawaited(
    widget.scheduleWidgetPlatform.writeAppearance(
      buildScheduleAppearance(widget.themeController),
    ),
  );

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
    _paletteLink.dispose();
    widget.themeController.removeListener(_syncScheduleAppearance);
    _scheduleWidget.dispose();
    _router.dispose();
    _routesViewModelsFactory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      Provider<MainPageRoutesViewModelsFactory>.value(
        value: _routesViewModelsFactory,
      ),
      ListenableProvider<AppThemeController>.value(
        value: widget.themeController,
      ),
    ],
    child: Consumer<AppThemeController>(
      builder: (context, themeController, _) => MaterialApp.router(
        routerConfig: _router.router,
        theme: AppTheme.lightThemeFor(
          themeController.lightTheme,
          custom: themeController.customLightPalette,
        ),
        darkTheme: AppTheme.darkThemeFor(
          themeController.darkTheme,
          custom: themeController.customDarkPalette,
        ),
        themeMode: themeController.mode,
        themeAnimationDuration: const Duration(milliseconds: 200),
      ),
    ),
  );
}
