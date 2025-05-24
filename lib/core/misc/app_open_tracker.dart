// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/app_version.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class _AppOpenTrackerProviderKeys {
  static const _firstAppOpen = 'firs_app_open';
}

class AppOpenTracker {
  final StorageService _storage;
  String? _lastVisitedVersion;

  AppOpenTracker(this._storage);

  String? get lastVisitedVersion => _lastVisitedVersion;

  Future<bool> isFirstTimeOpenOnVersion() async {
    final appVersion = await getAppVersion();

    _lastVisitedVersion ??= await _storage.read(
      key: _AppOpenTrackerProviderKeys._firstAppOpen,
    );
    final isFirstAppOpenForVersion =
        _lastVisitedVersion == null || appVersion != _lastVisitedVersion;

    if (isFirstAppOpenForVersion) {
      await _storage.write(
        key: _AppOpenTrackerProviderKeys._firstAppOpen,
        value: appVersion,
      );
    }
    return isFirstAppOpenForVersion;
  }
}
