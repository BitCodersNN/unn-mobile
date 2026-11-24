// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/models/common/app_dark_theme.dart';
import 'package:unn_mobile/core/models/common/app_light_theme.dart';
import 'package:unn_mobile/core/models/common/app_theme_mode.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';

abstract interface class AppThemeController implements Listenable {
  AppThemeMode get mode;
  AppLightTheme get lightTheme;
  AppDarkTheme get darkTheme;
  CustomPaletteConfig? get customLightPalette;
  CustomPaletteConfig? get customDarkPalette;
  bool get hasCustomLightPalette;
  bool get hasCustomDarkPalette;

  Future<void> load();
  Future<void> reload();
  Future<void> setMode(AppThemeMode mode);
  Future<void> setLightTheme(AppLightTheme theme);
  Future<void> setDarkTheme(AppDarkTheme theme);
  Future<void> setCustomLightPalette(CustomPaletteConfig config);
  Future<void> setCustomDarkPalette(CustomPaletteConfig config);
  Future<void> applyCustomPalette(
    CustomPaletteConfig config, {
    required Brightness brightness,
  });
}
