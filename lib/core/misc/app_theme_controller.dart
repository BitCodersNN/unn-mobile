// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/models/common/app_dark_theme.dart';
import 'package:unn_mobile/core/models/common/app_light_theme.dart';
import 'package:unn_mobile/core/models/common/app_theme_mode.dart';
import 'package:unn_mobile/core/providers/interfaces/common/app_theme_provider.dart';

class AppThemeController extends ChangeNotifier {
  final AppThemeProvider _provider;
  final _mode = _ThemePreference(AppThemeMode.system);
  final _lightTheme = _ThemePreference(AppLightTheme.classic);
  final _darkTheme = _ThemePreference(AppDarkTheme.green);

  AppThemeController(this._provider);

  AppThemeMode get mode => _mode.value;
  AppLightTheme get lightTheme => _lightTheme.value;
  AppDarkTheme get darkTheme => _darkTheme.value;

  Future<void> load() async {
    final (mode, lightTheme, darkTheme) = await (
      _provider.read(),
      _provider.readLightTheme(),
      _provider.readDarkTheme(),
    ).wait;
    _mode.load(mode);
    _lightTheme.load(lightTheme);
    _darkTheme.load(darkTheme);
    notifyListeners();
  }

  Future<void> setMode(AppThemeMode mode) =>
      _mode.update(mode, save: _provider.save, onChanged: notifyListeners);

  Future<void> setLightTheme(AppLightTheme theme) => _lightTheme.update(
    theme,
    save: _provider.saveLightTheme,
    onChanged: notifyListeners,
  );

  Future<void> setDarkTheme(AppDarkTheme theme) => _darkTheme.update(
    theme,
    save: _provider.saveDarkTheme,
    onChanged: notifyListeners,
  );
}

class _ThemePreference<T extends Enum> {
  T _value;
  T _savedValue;
  int _revision = 0;

  _ThemePreference(T value) : _value = value, _savedValue = value;

  T get value => _value;

  void load(T value) {
    _value = value;
    _savedValue = value;
  }

  Future<void> update(
    T value, {
    required Future<void> Function(T) save,
    required VoidCallback onChanged,
  }) async {
    if (value == _value) {
      return;
    }
    final revision = ++_revision;
    _value = value;
    onChanged();
    try {
      await save(value);
    } catch (_) {
      if (revision == _revision) {
        _value = _savedValue;
        onChanged();
      }
      rethrow;
    }
    _savedValue = value;
  }
}
