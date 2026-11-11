// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/models/grade_book/mark_type.dart';
import 'package:unn_mobile/core/models/schedule/subject_type.dart';

class UnnMobileColors extends ThemeExtension<UnnMobileColors> {
  final Color? scheduleDayHighlight;
  final Color? scheduleSubjectHighlight;
  final Map<SubjectType, Color>? scheduleSubjectTypeColors;
  final Map<MarkType, Color>? gradeMarkTypeColors;
  final Color? ligtherTextColor;
  final Color? idkWhatColor;
  final Color? wideButtonBottomColor;
  final Color shimmerBaseColor;
  final Color shimmerHighlightColor;

  const UnnMobileColors({
    required this.scheduleDayHighlight,
    required this.scheduleSubjectHighlight,
    required this.scheduleSubjectTypeColors,
    required this.gradeMarkTypeColors,
    required this.ligtherTextColor,
    required this.idkWhatColor,
    required this.wideButtonBottomColor,
    required this.shimmerBaseColor,
    required this.shimmerHighlightColor,
  });

  static const light = UnnMobileColors(
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
    shimmerBaseColor: Color(0xFFEBEBF4),
    shimmerHighlightColor: Color(0xFFF4F4F4),
  );

  static const dark = UnnMobileColors(
    scheduleDayHighlight: Color(0xFF293F39),
    scheduleSubjectHighlight: Color(0xFF3B3426),
    scheduleSubjectTypeColors: {
      SubjectType.lecture: Color(0xFF79C8BF),
      SubjectType.practice: Color(0xFFD99A80),
      SubjectType.lab: Color(0xFF8FB8E8),
      SubjectType.exam: Color(0xFFD49DBB),
      SubjectType.consult: Color(0xFFB5A1DD),
      SubjectType.unknown: Color(0xFFA9B8B2),
    },
    gradeMarkTypeColors: {
      MarkType.perfect: Color(0xFF8AC7A1),
      MarkType.excellent: Color(0xFF8AC7A1),
      MarkType.veryGood: Color(0xFFD6C183),
      MarkType.good: Color(0xFFD6C183),
      MarkType.satisfactory: Color(0xFFDFB28C),
      MarkType.notSatisfactory: Color(0xFFE3A298),
      MarkType.notCredited: Color(0xFFE3A298),
      MarkType.credited: Color(0xFF96B9E3),
      MarkType.noShow: Color(0xFFA9B8B2),
    },
    ligtherTextColor: Color(0xFFAFC5BE),
    idkWhatColor: Color(0xFF93ABA2),
    wideButtonBottomColor: Color(0xFF4CA99B),
    shimmerBaseColor: Color(0xFF203530),
    shimmerHighlightColor: Color(0xFF334A44),
  );

  static final graphite = dark.copyWith(
    scheduleDayHighlight: const Color(0xFF303040),
    scheduleSubjectHighlight: const Color(0xFF40362D),
    ligtherTextColor: const Color(0xFFC1BECE),
    idkWhatColor: const Color(0xFFAAA5B8),
    shimmerBaseColor: const Color(0xFF252532),
    shimmerHighlightColor: const Color(0xFF3D3D4D),
  );

  @override
  UnnMobileColors copyWith({
    Color? scheduleDayHighlight,
    Color? scheduleSubjectHighlight,
    Map<SubjectType, Color>? scheduleSubjectTypeColors,
    Map<MarkType, Color>? gradeMarkTypeColors,
    Color? ligtherTextColor,
    Color? idkWhatColor,
    Color? wideButtonTopColor,
    Color? wideButtonBottomColor,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
  }) => UnnMobileColors(
    scheduleDayHighlight: scheduleDayHighlight ?? this.scheduleDayHighlight,
    scheduleSubjectHighlight:
        scheduleSubjectHighlight ?? this.scheduleSubjectHighlight,
    scheduleSubjectTypeColors:
        scheduleSubjectTypeColors ?? this.scheduleSubjectTypeColors,
    gradeMarkTypeColors: gradeMarkTypeColors ?? this.gradeMarkTypeColors,
    ligtherTextColor: ligtherTextColor ?? this.ligtherTextColor,
    idkWhatColor: idkWhatColor ?? this.idkWhatColor,
    wideButtonBottomColor: wideButtonBottomColor ?? this.wideButtonBottomColor,
    shimmerBaseColor: shimmerBaseColor ?? this.shimmerBaseColor,
    shimmerHighlightColor: shimmerHighlightColor ?? this.shimmerHighlightColor,
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
      scheduleSubjectTypeColors: Map.fromIterables(
        scheduleSubjectTypeColors!.keys,
        scheduleSubjectTypeColors!.keys.map((SubjectType key) {
          final Color thisColor = scheduleSubjectTypeColors![key]!;
          final Color otherColor = otherColors.scheduleSubjectTypeColors![key]!;
          return Color.lerp(thisColor, otherColor, t) ?? thisColor;
        }),
      ),
      gradeMarkTypeColors: Map.fromIterables(
        gradeMarkTypeColors!.keys,
        gradeMarkTypeColors!.keys.map((MarkType key) {
          final Color thisColor = gradeMarkTypeColors![key]!;
          final Color otherColor = otherColors.gradeMarkTypeColors![key]!;
          return Color.lerp(thisColor, otherColor, t) ?? thisColor;
        }),
      ),
      ligtherTextColor: Color.lerp(
        ligtherTextColor,
        otherColors.ligtherTextColor,
        t,
      ),
      idkWhatColor: Color.lerp(idkWhatColor, otherColors.idkWhatColor, t),
      wideButtonBottomColor: Color.lerp(
        wideButtonBottomColor,
        otherColors.wideButtonBottomColor,
        t,
      ),
      shimmerBaseColor: Color.lerp(
        shimmerBaseColor,
        otherColors.shimmerBaseColor,
        t,
      )!,
      shimmerHighlightColor: Color.lerp(
        shimmerHighlightColor,
        otherColors.shimmerHighlightColor,
        t,
      )!,
    );
  }
}

extension ThemeDataExtension on ThemeData {
  Color get subduedButtonBackgroundColor => Color.alphaBlend(
    colorScheme.primary.withValues(alpha: 0.18),
    colorScheme.surfaceContainerLowest,
  );

  Color get alternatingSurfaceColor => colorScheme.primary.withAlpha(20);

  Color getColorOfMarkType(MarkType? markType) {
    if (markType == null) {
      return colorScheme.onSurfaceVariant;
    }
    final extraColors = extension<UnnMobileColors>()!;
    return extraColors.gradeMarkTypeColors![markType] ?? primaryColor;
  }

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

    return isEven ? alternatingSurfaceColor : colorScheme.surface;
  }

  UnnMobileColors? get unnMobileColors => extension<UnnMobileColors>();
}
