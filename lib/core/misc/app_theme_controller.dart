// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/models/common/app_dark_theme.dart';
import 'package:unn_mobile/core/models/common/app_light_theme.dart';
import 'package:unn_mobile/core/models/common/app_theme_mode.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/core/providers/interfaces/common/app_theme_provider.dart';

class AppThemeController extends ChangeNotifier {
  final AppThemeProvider _provider;
  final _mode = _ThemePreference(AppThemeMode.system);
  final _lightTheme = _ThemePreference(AppLightTheme.green);
  final _darkTheme = _ThemePreference(AppDarkTheme.green);
  final _customLightPalette = _ThemePreference<CustomPaletteConfig?>(null);
  final _customDarkPalette = _ThemePreference<CustomPaletteConfig?>(null);

  AppThemeController(this._provider);

  AppThemeMode get mode => _mode.value;
  AppLightTheme get lightTheme => _lightTheme.value;
  AppDarkTheme get darkTheme => _darkTheme.value;
  CustomPaletteConfig? get customLightPalette => _customLightPalette.value;
  CustomPaletteConfig? get customDarkPalette => _customDarkPalette.value;
  bool get hasCustomLightPalette => _customLightPalette.value != null;
  bool get hasCustomDarkPalette => _customDarkPalette.value != null;

  Future<void> load() async {
    final (mode, lightTheme, darkTheme, customLight, customDark) = await (
      _provider.read(),
      _provider.readLightTheme(),
      _provider.readDarkTheme(),
      _provider.readCustomLightPalette(),
      _provider.readCustomDarkPalette(),
    ).wait;
    _mode.load(mode);
    _lightTheme.load(lightTheme);
    _darkTheme.load(darkTheme);
    _customLightPalette.load(customLight);
    _customDarkPalette.load(customDark);
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

  Future<void> setCustomLightPalette(CustomPaletteConfig config) =>
      _updateCustomPalette(
        _customLightPalette,
        config,
        _provider.saveCustomLightPalette,
      );

  Future<void> setCustomDarkPalette(CustomPaletteConfig config) =>
      _updateCustomPalette(
        _customDarkPalette,
        config,
        _provider.saveCustomDarkPalette,
      );

  Future<void> applyCustomPalette(
    CustomPaletteConfig config, {
    required Brightness brightness,
  }) async {
    if (brightness == Brightness.dark) {
      await setCustomDarkPalette(config);
      await setDarkTheme(AppDarkTheme.custom);
    } else {
      await setCustomLightPalette(config);
      await setLightTheme(AppLightTheme.custom);
    }
  }

  Future<void> _updateCustomPalette(
    _ThemePreference<CustomPaletteConfig?> preference,
    CustomPaletteConfig config,
    Future<void> Function(CustomPaletteConfig) save,
  ) => preference.update(
    config,
    save: (value) => value == null ? Future<void>.value() : save(value),
    onChanged: notifyListeners,
  );
}

class _ThemePreference<T> {
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
