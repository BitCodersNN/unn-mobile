// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/core/models/grade_book/mark_type.dart';
import 'package:unn_mobile/core/models/schedule/subject_type.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';

abstract final class CustomPaletteThemeBuilder {
  static ThemeData build(
    CustomPaletteConfig config, {
    required Brightness brightness,
    required ColorScheme Function(Color seed, {Color? secondary})
    darkColorsFactory,
    required ThemeData Function(
      ColorScheme colors,
      UnnMobileColors extraColors, {
      Color? snackBarActionColor,
      Color? cardColor,
    })
    themeFactory,
  }) {
    final isDark = brightness == Brightness.dark;
    final overrides = config.overrides;
    final baseScheme = isDark
        ? darkColorsFactory(config.primary, secondary: config.secondary)
        : ColorScheme.fromSeed(
            seedColor: config.primary,
            secondary: config.secondary,
          );

    final surfaceOverride = overrides[PaletteColorSlot.surface];
    final cardOverride = overrides[PaletteColorSlot.cardSurface];
    final effectiveSurface = surfaceOverride ?? baseScheme.surface;
    final primaryContainer = Color.lerp(
      config.primary,
      effectiveSurface,
      isDark ? 0.62 : 0.82,
    )!;
    final onPrimaryContainer =
        ThemeData.estimateBrightnessForColor(primaryContainer) ==
            Brightness.light
        ? Color.lerp(config.primary, const Color(0xFF06221E), 0.7)!
        : Color.lerp(config.primary, Colors.white, 0.78)!;

    var colorScheme = baseScheme.copyWith(
      primary: config.primary,
      onPrimary: _contrastForeground(config.primary),
      secondary: config.secondary,
      onSecondary: _contrastForeground(config.secondary),
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      onSurface: overrides[PaletteColorSlot.onSurface],
      onSurfaceVariant: overrides[PaletteColorSlot.onSurfaceVariant],
      outlineVariant: overrides[PaletteColorSlot.outlineVariant],
    );

    if (surfaceOverride != null) {
      colorScheme = colorScheme.copyWith(
        surface: surfaceOverride,
        surfaceContainerLow: Color.lerp(
          surfaceOverride,
          isDark ? Colors.white : Colors.black,
          isDark ? 0.04 : 0.025,
        ),
        surfaceDim: Color.lerp(
          surfaceOverride,
          Colors.black,
          isDark ? 0.25 : 0.12,
        ),
        surfaceBright: Color.lerp(
          surfaceOverride,
          Colors.white,
          isDark ? 0.18 : 0.5,
        ),
        surfaceContainerLowest: isDark
            ? Color.lerp(surfaceOverride, Colors.white, 0.08)
            : Color.lerp(surfaceOverride, Colors.white, 0.7),
      );
    }

    if (cardOverride != null) {
      final stepTarget = isDark ? Colors.white : Colors.black;
      colorScheme = colorScheme.copyWith(
        surfaceContainerLowest: cardOverride,
        surfaceContainer: cardOverride,
        surfaceContainerHigh: Color.lerp(
          cardOverride,
          stepTarget,
          isDark ? 0.06 : 0.04,
        ),
        surfaceContainerHighest: Color.lerp(
          cardOverride,
          stepTarget,
          isDark ? 0.12 : 0.08,
        ),
      );
    }

    final baseExtra = isDark ? UnnMobileColors.dark : UnnMobileColors.light;
    final baseSubjects = baseExtra.scheduleSubjectTypeColors!;
    final baseMarks = baseExtra.gradeMarkTypeColors!;

    final extraColors = baseExtra.copyWith(
      scheduleDayHighlight: overrides[PaletteColorSlot.scheduleDayHighlight],
      scheduleSubjectHighlight:
          overrides[PaletteColorSlot.scheduleSubjectHighlight],
      scheduleSubjectTypeColors: {
        SubjectType.lecture:
            overrides[PaletteColorSlot.subjectLecture] ??
            baseSubjects[SubjectType.lecture]!,
        SubjectType.practice:
            overrides[PaletteColorSlot.subjectPractice] ??
            baseSubjects[SubjectType.practice]!,
        SubjectType.lab:
            overrides[PaletteColorSlot.subjectLab] ??
            baseSubjects[SubjectType.lab]!,
        SubjectType.exam:
            overrides[PaletteColorSlot.subjectExam] ??
            baseSubjects[SubjectType.exam]!,
        SubjectType.consult:
            overrides[PaletteColorSlot.subjectConsult] ??
            baseSubjects[SubjectType.consult]!,
        SubjectType.unknown:
            overrides[PaletteColorSlot.subjectUnknown] ??
            baseSubjects[SubjectType.unknown]!,
      },
      gradeMarkTypeColors: {
        MarkType.perfect:
            overrides[PaletteColorSlot.markExcellent] ??
            baseMarks[MarkType.perfect]!,
        MarkType.excellent:
            overrides[PaletteColorSlot.markExcellent] ??
            baseMarks[MarkType.excellent]!,
        MarkType.veryGood:
            overrides[PaletteColorSlot.markGood] ??
            baseMarks[MarkType.veryGood]!,
        MarkType.good:
            overrides[PaletteColorSlot.markGood] ?? baseMarks[MarkType.good]!,
        MarkType.satisfactory:
            overrides[PaletteColorSlot.markSatisfactory] ??
            baseMarks[MarkType.satisfactory]!,
        MarkType.notSatisfactory:
            overrides[PaletteColorSlot.markUnsatisfactory] ??
            baseMarks[MarkType.notSatisfactory]!,
        MarkType.notCredited:
            overrides[PaletteColorSlot.markUnsatisfactory] ??
            baseMarks[MarkType.notCredited]!,
        MarkType.credited:
            overrides[PaletteColorSlot.markCredited] ??
            baseMarks[MarkType.credited]!,
        MarkType.noShow:
            overrides[PaletteColorSlot.markNoShow] ??
            baseMarks[MarkType.noShow]!,
      },
      ligtherTextColor: overrides[PaletteColorSlot.onSurfaceVariant],
      importantPostHighlight:
          overrides[PaletteColorSlot.importantPostHighlight],
      wideButtonBottomColor:
          overrides[PaletteColorSlot.wideButtonBottom] ??
          Color.lerp(config.primary, config.secondary, 0.7),
      shimmerBaseColor: overrides[PaletteColorSlot.shimmerBase],
      shimmerHighlightColor: overrides[PaletteColorSlot.shimmerHighlight],
    );

    return themeFactory(colorScheme, extraColors, cardColor: cardOverride);
  }

  static CustomPaletteConfig configFromTheme(ThemeData theme) {
    final scheme = theme.colorScheme;
    final wideButtonBottom = theme.unnMobileColors?.wideButtonBottomColor;
    return CustomPaletteConfig(
      primary: scheme.primary,
      secondary: scheme.secondary,
      overrides: {
        PaletteColorSlot.surface: scheme.surface,
        PaletteColorSlot.cardSurface: scheme.surfaceContainerLowest,
        PaletteColorSlot.onSurface: scheme.onSurface,
        PaletteColorSlot.onSurfaceVariant: scheme.onSurfaceVariant,
        PaletteColorSlot.outlineVariant: scheme.outlineVariant,
        if (wideButtonBottom != null)
          PaletteColorSlot.wideButtonBottom: wideButtonBottom,
      },
    );
  }

  static Color colorForSlot(ThemeData theme, PaletteColorSlot slot) {
    final scheme = theme.colorScheme;
    final extra = theme.unnMobileColors!;
    return switch (slot) {
      PaletteColorSlot.primary => scheme.primary,
      PaletteColorSlot.secondary => scheme.secondary,
      PaletteColorSlot.surface => scheme.surface,
      PaletteColorSlot.cardSurface => scheme.surfaceContainerLowest,
      PaletteColorSlot.onSurface => scheme.onSurface,
      PaletteColorSlot.onSurfaceVariant => scheme.onSurfaceVariant,
      PaletteColorSlot.outlineVariant => scheme.outlineVariant,
      PaletteColorSlot.importantPostHighlight =>
        extra.importantPostHighlight ?? scheme.error,
      PaletteColorSlot.wideButtonBottom => extra.wideButtonBottomColor!,
      PaletteColorSlot.scheduleDayHighlight => extra.scheduleDayHighlight!,
      PaletteColorSlot.scheduleSubjectHighlight =>
        extra.scheduleSubjectHighlight!,
      PaletteColorSlot.subjectLecture =>
        extra.scheduleSubjectTypeColors![SubjectType.lecture]!,
      PaletteColorSlot.subjectPractice =>
        extra.scheduleSubjectTypeColors![SubjectType.practice]!,
      PaletteColorSlot.subjectLab =>
        extra.scheduleSubjectTypeColors![SubjectType.lab]!,
      PaletteColorSlot.subjectExam =>
        extra.scheduleSubjectTypeColors![SubjectType.exam]!,
      PaletteColorSlot.subjectConsult =>
        extra.scheduleSubjectTypeColors![SubjectType.consult]!,
      PaletteColorSlot.subjectUnknown =>
        extra.scheduleSubjectTypeColors![SubjectType.unknown]!,
      PaletteColorSlot.markExcellent =>
        extra.gradeMarkTypeColors![MarkType.excellent]!,
      PaletteColorSlot.markGood => extra.gradeMarkTypeColors![MarkType.good]!,
      PaletteColorSlot.markSatisfactory =>
        extra.gradeMarkTypeColors![MarkType.satisfactory]!,
      PaletteColorSlot.markUnsatisfactory =>
        extra.gradeMarkTypeColors![MarkType.notSatisfactory]!,
      PaletteColorSlot.markCredited =>
        extra.gradeMarkTypeColors![MarkType.credited]!,
      PaletteColorSlot.markNoShow =>
        extra.gradeMarkTypeColors![MarkType.noShow]!,
      PaletteColorSlot.shimmerBase => extra.shimmerBaseColor,
      PaletteColorSlot.shimmerHighlight => extra.shimmerHighlightColor,
    };
  }

  static Color _contrastForeground(Color color) =>
      ThemeData.estimateBrightnessForColor(color) == Brightness.light
      ? const Color(0xFF06221E)
      : Colors.white;
}
