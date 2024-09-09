import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/subject.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';

class UnnMobile extends StatelessWidget {
  const UnnMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: mainRouter,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          elevation: 0,
        ),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xAA1A63B7),
          background: const Color(0xFFF9FAFF),
          surface: const Color(0xFFFFFFFF),
          surfaceVariant: const Color(0xFFEFF1FB),
        ),
        textTheme: Typography.blackRedwoodCity,
        extensions: const [
          UnnMobileColors(
            scheduleDayHighlight: Color(0xFFEEEEEE),
            scheduleSubjectHighlight: Color(0xFFFFF6E8),
            defaultPostHighlight: Color(0xFFFFFFFF),
            newPostHiglaght: Color(0xFFFFF6E8),
            subjectTypeHighlight: {
              SubjectType.lecture: Color(0xFF1CA49C),
              SubjectType.practice: Color(0xFFCD7255),
              SubjectType.lab: Color(0xFF0961FF),
              SubjectType.exam: Color(0xFFAA4B7E),
              SubjectType.consult: Color(0xFF7D60D1),
              SubjectType.unknown: Color(0xFF6E757C),
            },
            ligtherTextColor: Color(0xFF717A84),
          ),
        ],
      ),
    );
  }
}
