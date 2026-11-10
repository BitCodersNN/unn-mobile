// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/common/app_theme_mode.dart';

abstract interface class AppThemeProvider {
  /// Возвращает сохранённый режим оформления.
  Future<AppThemeMode> read();

  /// Сохраняет режим оформления.
  Future<void> save(AppThemeMode mode);
}
