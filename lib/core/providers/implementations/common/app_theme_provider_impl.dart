// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/constants/string_keys/app_settings_keys.dart';
import 'package:unn_mobile/core/models/common/app_theme_mode.dart';
import 'package:unn_mobile/core/providers/interfaces/common/app_theme_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class AppThemeProviderImpl implements AppThemeProvider {
  final StorageService _storage;
  Future<void> _pendingSave = Future<void>.value();

  AppThemeProviderImpl(this._storage);

  @override
  Future<AppThemeMode> read() async {
    final saved = await _storage.read(key: AppSettingsKeys.themeMode);
    return AppThemeMode.values
            .where((mode) => mode.name == saved)
            .firstOrNull ??
        AppThemeMode.system;
  }

  @override
  Future<void> save(AppThemeMode mode) {
    Future<void> write() =>
        _storage.write(key: AppSettingsKeys.themeMode, value: mode.name);
    return _pendingSave = _pendingSave.then(
      (_) => write(),
      onError: (Object _, StackTrace _) => write(),
    );
  }
}
