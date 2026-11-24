// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/file_helpers/file_functions.dart';
import 'package:unn_mobile/core/misc/schedule_activity/schedule_activity_platform.dart';
import 'package:unn_mobile/core/models/common/app_dark_theme.dart';
import 'package:unn_mobile/core/models/common/app_light_theme.dart';
import 'package:unn_mobile/core/models/common/app_theme_mode.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/core/models/schedule_activity/schedule_activity_capabilities.dart';
import 'package:unn_mobile/core/models/schedule_activity/schedule_activity_mode.dart';
import 'package:unn_mobile/core/models/schedule_activity/schedule_activity_settings.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/source_authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/unn_authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/app_theme_controller.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_widget/schedule_widget_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class SettingsScreenViewModel extends BaseViewModel {
  final AppThemeController _themeController;
  final StorageService _storageService;
  final ScheduleWidgetService _scheduleWidget;
  final ScheduleActivityPlatform _activityPlatform;
  ScheduleActivityCapabilities? _activityStatus;

  ScheduleActivityCapabilities? get activityStatus => _activityStatus;

  ScheduleActivitySettings get activitySettings =>
      AppSettings.scheduleActivity.value;

  Future<void> refreshActivityStatus() async {
    _activityStatus = await _activityPlatform.status();
    notifyListeners();
  }

  Future<void> updateActivitySettings(ScheduleActivitySettings settings) async {
    if (settings.mode != ScheduleActivityMode.disabled &&
        activitySettings.mode == ScheduleActivityMode.disabled) {
      await _activityPlatform.requestPermission();
    }
    await AppSettings.updateScheduleActivity(settings);
    await refreshActivityStatus();
  }

  Future<bool> openSystemAppSettings() =>
      PermissionHandlerPlatform.instance.openAppSettings();

  Future<void> openActivitySettings({bool exactAlarms = false}) =>
      _activityPlatform.openSystemSettings(exactAlarms: exactAlarms);

  final UnnAuthService _authorizationService;
  final SourceAuthService _sourceAuthorizationService;

  SettingsScreenViewModel(
    this._themeController,
    this._storageService,
    this._authorizationService,
    this._sourceAuthorizationService,
    this._scheduleWidget,
    this._activityPlatform,
  ) {
    _themeController.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _themeController.removeListener(notifyListeners);
    super.dispose();
  }

  AppThemeMode get themeMode => _themeController.mode;
  AppLightTheme get lightTheme => _themeController.lightTheme;
  AppDarkTheme get darkTheme => _themeController.darkTheme;
  CustomPaletteConfig? get customLightPalette =>
      customPalette(Brightness.light);
  CustomPaletteConfig? get customDarkPalette => customPalette(Brightness.dark);
  bool get hasCustomLightPalette => hasCustomPalette(Brightness.light);
  bool get hasCustomDarkPalette => hasCustomPalette(Brightness.dark);

  CustomPaletteConfig? customPalette(Brightness brightness) =>
      brightness == Brightness.dark
      ? _themeController.customDarkPalette
      : _themeController.customLightPalette;

  bool hasCustomPalette(Brightness brightness) => brightness == Brightness.dark
      ? _themeController.hasCustomDarkPalette
      : _themeController.hasCustomLightPalette;

  Future<void> setThemeMode(AppThemeMode mode) =>
      _updateTheme(() => _themeController.setMode(mode));

  Future<void> setLightTheme(AppLightTheme theme) =>
      _updateTheme(() => _themeController.setLightTheme(theme));

  Future<void> setDarkTheme(AppDarkTheme theme) =>
      _updateTheme(() => _themeController.setDarkTheme(theme));

  Future<void> saveCustomPalette(
    CustomPaletteConfig config, {
    required Brightness brightness,
  }) => _updateTheme(
    () => _themeController.applyCustomPalette(config, brightness: brightness),
  );

  Future<void> saveCustomLightPalette(CustomPaletteConfig config) =>
      saveCustomPalette(config, brightness: Brightness.light);

  Future<void> saveCustomDarkPalette(CustomPaletteConfig config) =>
      saveCustomPalette(config, brightness: Brightness.dark);

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
    AppSettings.scheduleActivity.value = const ScheduleActivitySettings();
    await _activityPlatform.configure(AppSettings.scheduleActivity.value);
    await _scheduleWidget.clear();
    await Future.wait([_storageService.clear(), clearCache()]);
    await _themeController.reload();
  }

  Future<void> logout() async {
    await clearEverything();
    _authorizationService.logout();
    _sourceAuthorizationService.logout();
  }
}
