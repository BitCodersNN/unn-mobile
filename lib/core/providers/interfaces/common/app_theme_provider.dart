// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/common/app_dark_theme.dart';
import 'package:unn_mobile/core/models/common/app_theme_mode.dart';

abstract interface class AppThemeProvider {
  /// Возвращает сохранённый режим оформления.
  Future<AppThemeMode> read();

  /// Сохраняет режим оформления.
  Future<void> save(AppThemeMode mode);

  /// Возвращает сохранённую тёмную палитру.
  Future<AppDarkTheme> readDarkTheme();

  /// Сохраняет тёмную палитру независимо от режима оформления.
  Future<void> saveDarkTheme(AppDarkTheme theme);
}
