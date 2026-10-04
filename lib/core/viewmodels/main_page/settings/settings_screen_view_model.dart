// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/file_helpers/file_functions.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class SettingsScreenViewModel extends BaseViewModel {
  final StorageService _storageService;

  SettingsScreenViewModel(this._storageService);

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
    await Future.wait([
      DefaultCacheManager().emptyCache(),
      clearCacheFolder(),
    ]);
  }

  Future<void> clearEverything() async {
    await Future.wait([
      _storageService.clear(),
      clearCache(),
    ]);
  }

  Future<void> logout() async {
    await clearEverything();
  }
}
