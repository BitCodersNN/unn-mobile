// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unn_mobile/core/constants/main_page_paths.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/schedule/subject_type.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_widget/schedule_widget_platform.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_widget/schedule_widget_service.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/schedule/schedule_screen_view_model.dart';
import 'package:unn_mobile/ui/home_widget/schedule_widget_binding.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';

class UnnMobile extends StatefulWidget {
  final MainPageRoutesViewModelsFactory routesViewModelsFactory;
  final CurrentUserSyncStorage currentUserStorage;
  final ScheduleWidgetPlatform scheduleWidgetPlatform;
  final ScheduleWidgetService scheduleWidgetService;

  const UnnMobile({
    required this.routesViewModelsFactory,
    required this.currentUserStorage,
    required this.scheduleWidgetPlatform,
    required this.scheduleWidgetService,
    super.key,
  });

  @override
  State<UnnMobile> createState() => _UnnMobileState();

  ThemeData buildAppTheme(Brightness brightness) {
    const primaryColor = Color(0xFF00BBB0);
    return ThemeData(
      appBarTheme: const AppBarTheme(
        scrolledUnderElevation: 3,
        backgroundColor: Colors.white,
      ),
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF323232),
        contentTextStyle: TextStyle(color: Color(0xFFF0F0F0), fontSize: 16),
        actionTextColor: primaryColor,
      ),
      extensions: const [
        UnnMobileColors(
          scheduleDayHighlight: Color(0xFFEEEEEE),
          scheduleSubjectHighlight: Color(0xFFFFF6E8),
          scheduleSubjectTypeColors: {
            SubjectType.lecture: Color(0xFF1CA49C),
            SubjectType.practice: Color(0xFFCD7255),
            SubjectType.lab: Color(0xFF0961FF),
            SubjectType.exam: Color(0xFFAA4B7E),
            SubjectType.consult: Color(0xFF7D60D1),
            SubjectType.unknown: Color(0xFF6E757C),
          },
          ligtherTextColor: Color(0xFF717A84),
          idkWhatColor: Color(0xFF989EA9),
          wideButtonBottomColor: Color(0xFF006254),
        ),
      ],
    );
  }
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
        child: MaterialApp.router(
          routerConfig: _router.router,
          theme: widget.buildAppTheme(Brightness.light),
          themeMode: ThemeMode.system,
        ),
      );
}
