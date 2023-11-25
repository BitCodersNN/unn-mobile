import 'package:flutter/material.dart';

class UnnMobileColors extends ThemeExtension<UnnMobileColors> {
  final Color? scheduleDayHighlight;
  final Color? scheduleSubjectHighlight;

  const UnnMobileColors({
    required this.scheduleDayHighlight,
    required this.scheduleSubjectHighlight,
  });

  @override
  ThemeExtension<UnnMobileColors> copyWith({
    Color? scheduleDayHighlight,
    Color? scheduleSubjectHighlight,
  }) {
    return UnnMobileColors(
      scheduleDayHighlight: scheduleDayHighlight ?? this.scheduleDayHighlight,
      scheduleSubjectHighlight:
          scheduleSubjectHighlight ?? this.scheduleSubjectHighlight,
    );
  }

  @override
  ThemeExtension<UnnMobileColors> lerp(
      covariant ThemeExtension<UnnMobileColors>? other, double t) {
    if (other is! UnnMobileColors) {
      return this;
    }
    return UnnMobileColors(
      scheduleDayHighlight:
          Color.lerp(scheduleDayHighlight, other.scheduleDayHighlight, t),
      scheduleSubjectHighlight: Color.lerp(
          scheduleSubjectHighlight, other.scheduleSubjectHighlight, t),
    );
  }
}
