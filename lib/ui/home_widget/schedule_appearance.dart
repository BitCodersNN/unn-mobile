// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/app_theme_controller.dart';
import 'package:unn_mobile/core/models/schedule/subject_type.dart';
import 'package:unn_mobile/ui/theme/app_theme.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';

Map<String, Object> buildScheduleAppearance(AppThemeController controller) => {
  'mode': controller.mode.name,
  'light': 'light_${controller.lightTheme.name}',
  'dark': 'dark_${controller.darkTheme.name}',
  'palettes': {
    for (final palette in AppTheme.lightPalettesFor(
      controller.customLightPalette,
    ))
      'light_${palette.value.name}': _colors(palette.theme),
    for (final palette in AppTheme.darkPalettesFor(
      controller.customDarkPalette,
    ))
      'dark_${palette.value.name}': _colors(palette.theme),
  },
};

Map<String, Object> _colors(ThemeData theme) {
  final scheme = theme.colorScheme;
  return {
    'background': scheme.surface.toARGB32(),
    'text': scheme.onSurface.toARGB32(),
    'secondary': scheme.onSurfaceVariant.toARGB32(),
    'accent': scheme.primary.toARGB32(),
    'subjects': {
      for (final type in SubjectType.values)
        type.name: theme.getColorOfSubjectType(type).toARGB32(),
    },
  };
}
