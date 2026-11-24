// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/models/common/app_dark_theme.dart';
import 'package:unn_mobile/core/models/common/app_light_theme.dart';
import 'package:unn_mobile/core/models/common/app_theme_mode.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/core/providers/interfaces/common/app_theme_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/app_theme_controller.dart';

class AppThemeControllerImpl extends ChangeNotifier
    implements AppThemeController {
  final AppThemeProvider _provider;
  final _mode = _ThemePreference(AppThemeMode.system);
  final _lightTheme = _ThemePreference(AppLightTheme.green);
  final _darkTheme = _ThemePreference(AppDarkTheme.green);
  final _customLightPalette = _ThemePreference<CustomPaletteConfig?>(null);
  final _customDarkPalette = _ThemePreference<CustomPaletteConfig?>(null);

  AppThemeControllerImpl(this._provider);

  @override
  AppThemeMode get mode => _mode.value;

  @override
  AppLightTheme get lightTheme => _lightTheme.value;

  @override
  AppDarkTheme get darkTheme => _darkTheme.value;

  @override
  CustomPaletteConfig? get customLightPalette => _customLightPalette.value;

  @override
  CustomPaletteConfig? get customDarkPalette => _customDarkPalette.value;

  @override
  bool get hasCustomLightPalette => _customLightPalette.value != null;

  @override
  bool get hasCustomDarkPalette => _customDarkPalette.value != null;

  @override
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

  @override
  Future<void> reload() => load();

  @override
  Future<void> setMode(AppThemeMode mode) =>
      _mode.update(mode, save: _provider.save, onChanged: notifyListeners);

  @override
  Future<void> setLightTheme(AppLightTheme theme) => _lightTheme.update(
    theme,
    save: _provider.saveLightTheme,
    onChanged: notifyListeners,
  );

  @override
  Future<void> setDarkTheme(AppDarkTheme theme) => _darkTheme.update(
    theme,
    save: _provider.saveDarkTheme,
    onChanged: notifyListeners,
  );

  @override
  Future<void> setCustomLightPalette(CustomPaletteConfig config) =>
      _updateCustomPalette(
        _customLightPalette,
        config,
        _provider.saveCustomLightPalette,
      );

  @override
  Future<void> setCustomDarkPalette(CustomPaletteConfig config) =>
      _updateCustomPalette(
        _customDarkPalette,
        config,
        _provider.saveCustomDarkPalette,
      );

  @override
  Future<void> applyCustomPalette(
    CustomPaletteConfig config, {
    required Brightness brightness,
  }) => brightness == Brightness.dark
      ? _applyCustomPalette(
          config: config,
          palettePref: _customDarkPalette,
          themePref: _darkTheme,
          customTheme: AppDarkTheme.custom,
          savePalette: _provider.saveCustomDarkPalette,
          saveTheme: _provider.saveDarkTheme,
        )
      : _applyCustomPalette(
          config: config,
          palettePref: _customLightPalette,
          themePref: _lightTheme,
          customTheme: AppLightTheme.custom,
          savePalette: _provider.saveCustomLightPalette,
          saveTheme: _provider.saveLightTheme,
        );

  Future<void> _applyCustomPalette<T>({
    required CustomPaletteConfig config,
    required _ThemePreference<CustomPaletteConfig?> palettePref,
    required _ThemePreference<T> themePref,
    required T customTheme,
    required Future<void> Function(CustomPaletteConfig) savePalette,
    required Future<void> Function(T) saveTheme,
  }) async {
    final paletteRev = palettePref.stage(config);
    final themeRev = themePref.stage(customTheme);
    if (paletteRev == null && themeRev == null) {
      return;
    }
    notifyListeners();
    try {
      await _persistCustomPalette(
        config: config,
        paletteChanged: paletteRev != null,
        themeChanged: themeRev != null,
        customTheme: customTheme,
        savePalette: savePalette,
        saveTheme: saveTheme,
      );
    } catch (_) {
      final rolledBackPalette = palettePref.rollback(paletteRev);
      final rolledBackTheme = themePref.rollback(themeRev);
      if (rolledBackPalette || rolledBackTheme) {
        notifyListeners();
      }
      rethrow;
    }
    palettePref.commit(paletteRev, config);
    themePref.commit(themeRev, customTheme);
  }

  Future<void> _persistCustomPalette<T>({
    required CustomPaletteConfig config,
    required bool paletteChanged,
    required bool themeChanged,
    required T customTheme,
    required Future<void> Function(CustomPaletteConfig) savePalette,
    required Future<void> Function(T) saveTheme,
  }) async {
    if (paletteChanged) {
      await savePalette(config);
    }
    if (themeChanged) {
      await saveTheme(customTheme);
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
    ++_revision;
    _value = value;
    _savedValue = value;
  }

  int? stage(T value) {
    if (value == _value) {
      return null;
    }
    _value = value;
    return ++_revision;
  }

  void commit(int? revision, T value) {
    if (revision != null && revision == _revision) {
      _savedValue = value;
    }
  }

  bool rollback(int? revision) {
    if (revision == null || revision != _revision) {
      return false;
    }
    _value = _savedValue;
    return true;
  }

  Future<void> update(
    T value, {
    required Future<void> Function(T) save,
    required VoidCallback onChanged,
  }) async {
    final revision = stage(value);
    if (revision == null) {
      return;
    }
    onChanged();
    try {
      await save(value);
    } catch (_) {
      if (rollback(revision)) {
        onChanged();
      }
      rethrow;
    }
    commit(revision, value);
  }
}
