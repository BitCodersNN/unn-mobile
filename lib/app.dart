// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/grade_book/mark_type.dart';
import 'package:unn_mobile/core/models/schedule/subject_type.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';

class UnnMobile extends StatefulWidget {
  final MainPageRoutesViewModelsFactory routesViewModelsFactory;
  final CurrentUserSyncStorage currentUserStorage;

  const UnnMobile({
    required this.routesViewModelsFactory,
    required this.currentUserStorage,
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
        contentTextStyle: TextStyle(
          color: Color(0xFFF0F0F0),
          fontSize: 16,
        ),
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
          gradeMarkTypeColors: {
            MarkType.perfect: Color(0xFF15803D),
            MarkType.excellent: Color(0xFF15803D),
            MarkType.veryGood: Color(0xFF9A6700),
            MarkType.good: Color(0xFF9A6700),
            MarkType.satisfactory: Color(0xFFB45309),
            MarkType.notSatisfactory: Color(0xFFB42318),
            MarkType.notCredited: Color(0xFFB42318),
            MarkType.credited: Color(0xFF2563EB),
            MarkType.noShow: Color(0xFF64748B),
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
  late final AppRouter _router = AppRouter(userType: widget.currentUserStorage);

  @override
  void dispose() {
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
