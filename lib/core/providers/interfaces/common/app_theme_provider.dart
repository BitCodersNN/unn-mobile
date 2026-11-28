// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/app_dark_theme.dart';
import 'package:unn_mobile/core/models/common/app_light_theme.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';

abstract interface class AppThemeProvider {
  /// Возвращает сохранённый режим оформления.
  Future<ThemeMode> read();

  /// Сохраняет режим оформления.
  Future<void> save(ThemeMode mode);

  /// Возвращает сохранённую тёмную палитру.
  Future<AppDarkTheme> readDarkTheme();

  /// Сохраняет тёмную палитру независимо от режима оформления.
  Future<void> saveDarkTheme(AppDarkTheme theme);

  /// Возвращает сохранённую светлую палитру.
  Future<AppLightTheme> readLightTheme();

  /// Сохраняет светлую палитру независимо от режима оформления.
  Future<void> saveLightTheme(AppLightTheme theme);

  /// Возвращает сохранённую пользовательскую светлую палитру.
  Future<CustomPaletteConfig?> readCustomLightPalette();

  /// Сохраняет пользовательскую светлую палитру.
  Future<void> saveCustomLightPalette(CustomPaletteConfig config);

  /// Возвращает сохранённую пользовательскую тёмную палитру.
  Future<CustomPaletteConfig?> readCustomDarkPalette();

  /// Сохраняет пользовательскую тёмную палитру.
  Future<void> saveCustomDarkPalette(CustomPaletteConfig config);
}
