// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/schedule/subject_type.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';

class UnnMobile extends StatelessWidget {
  const UnnMobile({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: mainRouter,
        theme: buildAppTheme(Brightness.light),
        themeMode: ThemeMode.system,
      );

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
          defaultPostHighlight: Color(0xFFFFFFFF),
          importantPostHighlight: Color(0xFFFFE3AF),
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
        ),
      ],
    );
  }
}
