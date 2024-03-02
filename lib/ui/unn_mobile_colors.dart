import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/subject.dart';

class UnnMobileColors extends ThemeExtension<UnnMobileColors> {
  final Color? scheduleDayHighlight;
  final Color? scheduleSubjectHighlight;
  final Map<SubjectType, Color>? subjectTypeHighlight;

  const UnnMobileColors({
    required this.scheduleDayHighlight,
    required this.scheduleSubjectHighlight,
    required this.subjectTypeHighlight,
  });

  @override
  ThemeExtension<UnnMobileColors> copyWith({
    Color? scheduleDayHighlight,
    Color? scheduleSubjectHighlight,
    Map<SubjectType, Color>? subjectTypeHighlight,
  }) {
    return UnnMobileColors(
      scheduleDayHighlight: scheduleDayHighlight ?? this.scheduleDayHighlight,
      scheduleSubjectHighlight:
          scheduleSubjectHighlight ?? this.scheduleSubjectHighlight,
      subjectTypeHighlight: subjectTypeHighlight ?? this.subjectTypeHighlight,
    );
  }

  @override
  ThemeExtension<UnnMobileColors> lerp(covariant ThemeExtension<UnnMobileColors>? other, double t) {
   if (other == null || other.runtimeType != runtimeType) {
    return this;
  }

  UnnMobileColors otherColors = other as UnnMobileColors;

  return UnnMobileColors(
    scheduleDayHighlight: Color.lerp(
        scheduleDayHighlight, otherColors.scheduleDayHighlight, t),

    scheduleSubjectHighlight: Color.lerp(
        scheduleSubjectHighlight, otherColors.scheduleSubjectHighlight, t),

    subjectTypeHighlight: Map.fromIterables(
      subjectTypeHighlight!.keys,
      subjectTypeHighlight!.keys.map((SubjectType key) {
        final Color thisColor = subjectTypeHighlight![key]!;
        final Color otherColor = otherColors.subjectTypeHighlight![key]!;

        return Color.lerp(thisColor, otherColor, t) ?? thisColor;
      }),
    ),
  );
  }
}
