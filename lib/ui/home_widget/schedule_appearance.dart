// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/app_dark_theme.dart';
import 'package:unn_mobile/core/models/common/app_light_theme.dart';
import 'package:unn_mobile/core/models/schedule/subject_type.dart';
import 'package:unn_mobile/core/services/interfaces/common/app_theme_controller.dart';
import 'package:unn_mobile/ui/theme/app_theme.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';

abstract final class _ScheduleAppearanceKeys {
  static const mode = 'mode';
  static const light = 'light';
  static const dark = 'dark';
  static const palettes = 'palettes';
  static const options = 'options';
  static const key = 'key';
  static const label = 'label';
  static const background = 'background';
  static const text = 'text';
  static const secondary = 'secondary';
  static const accent = 'accent';
  static const subjects = 'subjects';
  static const lightPrefix = 'light_';
  static const darkPrefix = 'dark_';
}

Map<String, Object> buildScheduleAppearance(AppThemeController controller) {
  final customLight = controller.customLightPalette;
  final customDark = controller.customDarkPalette;
  return {
    _ScheduleAppearanceKeys.mode: controller.mode.name,
    _ScheduleAppearanceKeys.light:
        '${_ScheduleAppearanceKeys.lightPrefix}${controller.lightTheme.name}',
    _ScheduleAppearanceKeys.dark:
        '${_ScheduleAppearanceKeys.darkPrefix}${controller.darkTheme.name}',
    _ScheduleAppearanceKeys.options: [
      for (final palette in AppTheme.lightPalettes)
        _option(
          key: '${_ScheduleAppearanceKeys.lightPrefix}${palette.value.name}',
          label: palette.label,
          isDark: false,
        ),
      if (customLight != null)
        _option(
          key:
              '${_ScheduleAppearanceKeys.lightPrefix}${AppLightTheme.custom.name}',
          label: 'Своя светлая',
          isDark: false,
        ),
      for (final palette in AppTheme.darkPalettes)
        _option(
          key: '${_ScheduleAppearanceKeys.darkPrefix}${palette.value.name}',
          label: palette.label,
          isDark: true,
        ),
      if (customDark != null)
        _option(
          key:
              '${_ScheduleAppearanceKeys.darkPrefix}${AppDarkTheme.custom.name}',
          label: 'Своя тёмная',
          isDark: true,
        ),
    ],
    _ScheduleAppearanceKeys.palettes: {
      for (final palette in AppTheme.lightPalettes)
        '${_ScheduleAppearanceKeys.lightPrefix}${palette.value.name}': _colors(
          palette.theme,
          isDark: false,
        ),
      if (customLight != null)
        '${_ScheduleAppearanceKeys.lightPrefix}${AppLightTheme.custom.name}':
            _colors(
              AppTheme.buildCustomTheme(
                customLight,
                brightness: Brightness.light,
              ),
              isDark: false,
            ),
      for (final palette in AppTheme.darkPalettes)
        '${_ScheduleAppearanceKeys.darkPrefix}${palette.value.name}': _colors(
          palette.theme,
          isDark: true,
        ),
      if (customDark != null)
        '${_ScheduleAppearanceKeys.darkPrefix}${AppDarkTheme.custom.name}':
            _colors(
              AppTheme.buildCustomTheme(
                customDark,
                brightness: Brightness.dark,
              ),
              isDark: true,
            ),
    },
  };
}

Map<String, Object> _option({
  required String key,
  required String label,
  required bool isDark,
}) => {
  _ScheduleAppearanceKeys.key: key,
  _ScheduleAppearanceKeys.label: label,
  _ScheduleAppearanceKeys.dark: isDark,
};

Map<String, Object> _colors(ThemeData theme, {required bool isDark}) {
  final scheme = theme.colorScheme;
  return {
    _ScheduleAppearanceKeys.dark: isDark,
    _ScheduleAppearanceKeys.background: scheme.surface.toARGB32(),
    _ScheduleAppearanceKeys.text: scheme.onSurface.toARGB32(),
    _ScheduleAppearanceKeys.secondary: scheme.onSurfaceVariant.toARGB32(),
    _ScheduleAppearanceKeys.accent: scheme.primary.toARGB32(),
    _ScheduleAppearanceKeys.subjects: {
      for (final type in SubjectType.values)
        type.name: theme.getColorOfSubjectType(type).toARGB32(),
    },
  };
}
