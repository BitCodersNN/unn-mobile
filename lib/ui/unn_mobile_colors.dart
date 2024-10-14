import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/library.dart';

class UnnMobileColors extends ThemeExtension<UnnMobileColors> {
  final Color? scheduleDayHighlight;
  final Color? scheduleSubjectHighlight;
  final Color? defaultPostHighlight;
  final Color? newPostHighlight;
  final Map<SubjectType, Color>? subjectTypeHighlight;
  final Color? ligtherTextColor;

  const UnnMobileColors({
    required this.scheduleDayHighlight,
    required this.scheduleSubjectHighlight,
    required this.defaultPostHighlight,
    required this.newPostHighlight,
    required this.subjectTypeHighlight,
    required this.ligtherTextColor,
  });

  @override
  ThemeExtension<UnnMobileColors> copyWith({
    Color? scheduleDayHighlight,
    Color? scheduleSubjectHighlight,
    Color? defaultPostHighlight,
    Color? newPostHighlight,
    Map<SubjectType, Color>? subjectTypeHighlight,
    Color? ligtherTextColor,
  }) {
    return UnnMobileColors(
      scheduleDayHighlight: scheduleDayHighlight ?? this.scheduleDayHighlight,
      scheduleSubjectHighlight:
          scheduleSubjectHighlight ?? this.scheduleSubjectHighlight,
      defaultPostHighlight: defaultPostHighlight ?? this.defaultPostHighlight,
      newPostHighlight: newPostHighlight ?? this.newPostHighlight,
      subjectTypeHighlight: subjectTypeHighlight ?? this.subjectTypeHighlight,
      ligtherTextColor: ligtherTextColor ?? this.ligtherTextColor,
    );
  }

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
      newPostHighlight: Color.lerp(
        newPostHighlight,
        otherColors.newPostHighlight,
        t,
      ),
      subjectTypeHighlight: Map.fromIterables(
        subjectTypeHighlight!.keys,
        subjectTypeHighlight!.keys.map((SubjectType key) {
          final Color thisColor = subjectTypeHighlight![key]!;
          final Color otherColor = otherColors.subjectTypeHighlight![key]!;

          return Color.lerp(thisColor, otherColor, t) ?? thisColor;
        }),
      ),
      ligtherTextColor: Color.lerp(
        ligtherTextColor,
        otherColors.ligtherTextColor,
        t,
      ),
    );
  }
}
