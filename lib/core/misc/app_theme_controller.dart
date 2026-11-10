// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/models/common/app_theme_mode.dart';
import 'package:unn_mobile/core/providers/interfaces/common/app_theme_provider.dart';

class AppThemeController extends ChangeNotifier {
  final AppThemeProvider _provider;
  AppThemeMode _mode = AppThemeMode.system;
  AppThemeMode _savedMode = AppThemeMode.system;
  int _revision = 0;

  AppThemeController(this._provider);

  AppThemeMode get mode => _mode;

  Future<void> load() async {
    _mode = await _provider.read();
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
}
