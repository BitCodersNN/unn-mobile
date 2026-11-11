// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/app_theme_controller.dart';
import 'package:unn_mobile/core/misc/file_helpers/file_functions.dart';
import 'package:unn_mobile/core/models/common/app_dark_theme.dart';
import 'package:unn_mobile/core/models/common/app_light_theme.dart';
import 'package:unn_mobile/core/models/common/app_theme_mode.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/source_authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/unn_authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_widget/schedule_widget_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class SettingsScreenViewModel extends BaseViewModel {
  final AppThemeController _themeController;
  final StorageService _storageService;
  final ScheduleWidgetService _scheduleWidget;

  final UnnAuthService _authorizationService;
  final SourceAuthService _sourceAuthorizationService;

  SettingsScreenViewModel(
    this._themeController,
    this._storageService,
    this._authorizationService,
    this._sourceAuthorizationService,
    this._scheduleWidget,
  );

  AppThemeMode get themeMode => _themeController.mode;
  AppLightTheme get lightTheme => _themeController.lightTheme;
  AppDarkTheme get darkTheme => _themeController.darkTheme;

  Future<void> setThemeMode(AppThemeMode mode) =>
      _updateTheme(() => _themeController.setMode(mode));

  Future<void> setLightTheme(AppLightTheme theme) =>
      _updateTheme(() => _themeController.setLightTheme(theme));

  Future<void> setDarkTheme(AppDarkTheme theme) =>
      _updateTheme(() => _themeController.setDarkTheme(theme));

  Future<void> _updateTheme(Future<void> Function() update) async {
    try {
      await update();
    } finally {
      notifyListeners();
    }
  }

  bool get vibrationEnabled => AppSettings.vibrationEnabled;

  set vibrationEnabled(bool value) {
    AppSettings.vibrationEnabled = value;
    AppSettings.save();
    notifyListeners();
  }

  bool get analyticsEnabled => AppSettings.analyticsEnabled;

  set analyticsEnabled(bool value) {
    AppSettings.analyticsEnabled = value;
    AppSettings.save();
    notifyListeners();
  }

  bool get reverseComments => AppSettings.reverseComments;

  set reverseComments(bool value) {
    AppSettings.reverseComments = value;
    AppSettings.save();
    notifyListeners();
  }

  bool get useRaspSchedule => AppSettings.useRaspSchedule;

  set useRaspSchedule(bool value) {
    AppSettings.useRaspSchedule = value;
    AppSettings.save();
    notifyListeners();
  }

  Future<void> clearCache() async {
    await Future.wait([DefaultCacheManager().emptyCache(), clearCacheFolder()]);
  }

  Future<void> clearEverything() async {
    await _scheduleWidget.clear();
    await Future.wait([_storageService.clear(), clearCache()]);
  }

  Future<void> logout() async {
    await clearEverything();
    _authorizationService.logout();
    _sourceAuthorizationService.logout();
  }
}
