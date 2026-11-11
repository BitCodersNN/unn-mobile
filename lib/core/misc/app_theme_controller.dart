// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/models/common/app_dark_theme.dart';
import 'package:unn_mobile/core/models/common/app_theme_mode.dart';
import 'package:unn_mobile/core/providers/interfaces/common/app_theme_provider.dart';

class AppThemeController extends ChangeNotifier {
  final AppThemeProvider _provider;
  AppThemeMode _mode = AppThemeMode.system;
  AppThemeMode _savedMode = AppThemeMode.system;
  int _revision = 0;
  AppDarkTheme _darkTheme = AppDarkTheme.green;
  AppDarkTheme _savedDarkTheme = AppDarkTheme.green;
  int _darkThemeRevision = 0;

  AppThemeController(this._provider);

  AppThemeMode get mode => _mode;
  AppDarkTheme get darkTheme => _darkTheme;

  Future<void> load() async {
    final (mode, darkTheme) = await (
      _provider.read(),
      _provider.readDarkTheme(),
    ).wait;
    _mode = mode;
    _darkTheme = darkTheme;
    _savedDarkTheme = darkTheme;
    _savedMode = _mode;
    notifyListeners();
  }

  Future<void> setMode(AppThemeMode mode) async {
    if (mode == _mode) {
      return;
    }
    final revision = ++_revision;
    _mode = mode;
    notifyListeners();
    try {
      await _provider.save(mode);
    } catch (_) {
      if (revision == _revision) {
        _mode = _savedMode;
        notifyListeners();
      }
      rethrow;
    }
    _savedMode = mode;
  }

  Future<void> setDarkTheme(AppDarkTheme theme) async {
    if (theme == _darkTheme) {
      return;
    }
    final revision = ++_darkThemeRevision;
    _darkTheme = theme;
    notifyListeners();
    try {
      await _provider.saveDarkTheme(theme);
    } catch (_) {
      if (revision == _darkThemeRevision) {
        _darkTheme = _savedDarkTheme;
        notifyListeners();
      }
      rethrow;
    }
    _savedDarkTheme = theme;
  }
}
