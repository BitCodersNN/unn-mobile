// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/models/schedule/subject_type.dart';

class UnnMobileColors extends ThemeExtension<UnnMobileColors> {
  final Color? scheduleDayHighlight;
  final Color? scheduleSubjectHighlight;
  final Color? defaultPostHighlight;
  final Color? importantPostHighlight;
  final Map<SubjectType, Color>? scheduleSubjectTypeColors;
  final Color? ligtherTextColor;
  final Color? idkWhatColor;

  const UnnMobileColors({
    required this.scheduleDayHighlight,
    required this.scheduleSubjectHighlight,
    required this.defaultPostHighlight,
    required this.importantPostHighlight,
    required this.scheduleSubjectTypeColors,
    required this.ligtherTextColor,
    required this.idkWhatColor,
  });

  @override
  ThemeExtension<UnnMobileColors> copyWith({
    Color? scheduleDayHighlight,
    Color? scheduleSubjectHighlight,
    Color? defaultPostHighlight,
    Color? importantPostHighlight,
    Map<SubjectType, Color>? scheduleSubjectTypeColors,
    Color? ligtherTextColor,
    Color? idkWhatColor,
  }) =>
      UnnMobileColors(
        scheduleDayHighlight: scheduleDayHighlight ?? this.scheduleDayHighlight,
        scheduleSubjectHighlight:
            scheduleSubjectHighlight ?? this.scheduleSubjectHighlight,
        defaultPostHighlight: defaultPostHighlight ?? this.defaultPostHighlight,
        importantPostHighlight:
            importantPostHighlight ?? this.importantPostHighlight,
        scheduleSubjectTypeColors:
            scheduleSubjectTypeColors ?? this.scheduleSubjectTypeColors,
        ligtherTextColor: ligtherTextColor ?? this.ligtherTextColor,
        idkWhatColor: idkWhatColor ?? this.idkWhatColor,
      );

  @override
  ThemeExtension<UnnMobileColors> lerp(
    covariant ThemeExtension<UnnMobileColors>? other,
    double t,
  ) {
    if (other == null || other.runtimeType != runtimeType) {
      return this;
    }

    final UnnMobileColors otherColors = other as UnnMobileColors;

    return UnnMobileColors(
      scheduleDayHighlight: Color.lerp(
        scheduleDayHighlight,
        otherColors.scheduleDayHighlight,
        t,
      ),
      scheduleSubjectHighlight: Color.lerp(
        scheduleSubjectHighlight,
        otherColors.scheduleSubjectHighlight,
        t,
      ),
      defaultPostHighlight: Color.lerp(
        defaultPostHighlight,
        otherColors.defaultPostHighlight,
        t,
      ),
      importantPostHighlight: Color.lerp(
        importantPostHighlight,
        otherColors.importantPostHighlight,
        t,
      ),
      scheduleSubjectTypeColors: Map.fromIterables(
        scheduleSubjectTypeColors!.keys,
        scheduleSubjectTypeColors!.keys.map((SubjectType key) {
          final Color thisColor = scheduleSubjectTypeColors![key]!;
          final Color otherColor = otherColors.scheduleSubjectTypeColors![key]!;

          return Color.lerp(thisColor, otherColor, t) ?? thisColor;
        }),
      ),
      ligtherTextColor: Color.lerp(
        ligtherTextColor,
        otherColors.ligtherTextColor,
        t,
      ),
      idkWhatColor: Color.lerp(
        idkWhatColor,
        otherColors.idkWhatColor,
        t,
      ),
    );
  }
}

extension ThemeDataExtension on ThemeData {
  Color getColorOfSubjectType(SubjectType subjectType) {
    final extraColors = extension<UnnMobileColors>()!;
    return extraColors.scheduleSubjectTypeColors![subjectType] ?? primaryColor;
  }

  Color getScheduleSurfaceColor(
    DateTimeRange dateTimeRange, {
    bool isEven = false,
  }) {
    final extraColors = extension<UnnMobileColors>()!;
    if (DateTime.now().isBetween(
      dateTimeRange.start.subtract(const Duration(minutes: 10)),
      dateTimeRange.end,
    )) {
      return extraColors.scheduleSubjectHighlight!;
    }

    return isEven ? colorScheme.surfaceContainerHighest : colorScheme.surface;
  }

  UnnMobileColors? get unnMobileColors => extension<UnnMobileColors>();
}
