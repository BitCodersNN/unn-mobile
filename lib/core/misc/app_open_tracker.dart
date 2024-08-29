import 'package:package_info_plus/package_info_plus.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';

class _AppOpenTrackerProviderKeys {
  static const _firstAppOpen = 'firs_app_open';
}

class AppOpenTracker {
  final StorageService storage;
  String? _lastVisitedVersion;

  AppOpenTracker(this.storage);

  String? get lastVisitedVersion => _lastVisitedVersion;

  Future<bool> isFirstTimeOpenOnVersion() async {
    final appVersion = await _getAppVersion();

    _lastVisitedVersion ??= await storage.read(
      key: _AppOpenTrackerProviderKeys._firstAppOpen,
    );
    final isFirstAppOpenForVersion =
        _lastVisitedVersion == null || appVersion != _lastVisitedVersion;

    if (isFirstAppOpenForVersion) {
      await storage.write(
        key: _AppOpenTrackerProviderKeys._firstAppOpen,
        value: appVersion,
      );
    }
    return isFirstAppOpenForVersion;
  }

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}
