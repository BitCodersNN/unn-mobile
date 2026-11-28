// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/string_keys/app_settings_keys.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/common/app_dark_theme.dart';
import 'package:unn_mobile/core/models/common/app_light_theme.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/core/providers/interfaces/common/app_theme_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class AppThemeProviderImpl implements AppThemeProvider {
  final StorageService _storage;
  Future<void> _pendingSave = Future<void>.value();

  AppThemeProviderImpl(this._storage);

  @override
  Future<ThemeMode> read() =>
      _readEnum(AppSettingsKeys.themeMode, ThemeMode.values, ThemeMode.system);

  @override
  Future<AppDarkTheme> readDarkTheme() => _readEnum(
    AppSettingsKeys.darkTheme,
    AppDarkTheme.values,
    AppDarkTheme.green,
  );

  @override
  Future<AppLightTheme> readLightTheme() => _readEnum(
    AppSettingsKeys.lightTheme,
    AppLightTheme.values,
    AppLightTheme.green,
  );

  Future<T> _readEnum<T extends Enum>(
    String key,
    List<T> values,
    T fallback,
  ) async {
    final saved = await _storage.read(key: key);
    return values.where((value) => value.name == saved).firstOrNull ?? fallback;
  }

  @override
  Future<void> save(ThemeMode mode) =>
      _saveValue(AppSettingsKeys.themeMode, mode.name);

  @override
  Future<void> saveDarkTheme(AppDarkTheme theme) =>
      _saveValue(AppSettingsKeys.darkTheme, theme.name);

  @override
  Future<void> saveLightTheme(AppLightTheme theme) =>
      _saveValue(AppSettingsKeys.lightTheme, theme.name);

  @override
  Future<CustomPaletteConfig?> readCustomLightPalette() =>
      _readCustomPalette(AppSettingsKeys.customLightPalette);

  @override
  Future<void> saveCustomLightPalette(CustomPaletteConfig config) => _saveValue(
    AppSettingsKeys.customLightPalette,
    jsonEncode(config.toJson()),
  );

  @override
  Future<CustomPaletteConfig?> readCustomDarkPalette() =>
      _readCustomPalette(AppSettingsKeys.customDarkPalette);

  @override
  Future<void> saveCustomDarkPalette(CustomPaletteConfig config) => _saveValue(
    AppSettingsKeys.customDarkPalette,
    jsonEncode(config.toJson()),
  );

  Future<CustomPaletteConfig?> _readCustomPalette(String key) async {
    final saved = await _storage.read(key: key);
    if (saved == null) {
      return null;
    }
    return CustomPaletteConfig.tryFromJson(tryDecodeJson(saved));
  }

  Future<void> _saveValue(String key, String value) {
    Future<void> write() => _storage.write(key: key, value: value);
    return _pendingSave = _pendingSave.then(
      (_) => write(),
      onError: (Object _, StackTrace _) => write(),
    );
  }
}
