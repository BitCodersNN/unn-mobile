// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:unn_mobile/core/misc/app_flavor.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_target.dart';

class AnnouncementEnvironmentProvider {
  final CurrentUserSyncStorage? _currentUserStorage;

  const AnnouncementEnvironmentProvider(this._currentUserStorage);

  Future<AnnouncementEnvironment> load() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final flavor = AppFlavor.current();
    final storeName = switch (flavor) {
      AppFlavor.regular || AppFlavor.regularTest => 'regular',
      AppFlavor.rustore || AppFlavor.rustoreTest => 'rustore',
      AppFlavor.googlePlay || AppFlavor.googlePlayTest => 'googlePlay',
    };
    return AnnouncementEnvironment(
      appVersion: packageInfo.version,
      buildNumber: int.tryParse(packageInfo.buildNumber) ?? 0,
      isTesting: flavor.isTesting,
      storeName: storeName,
      platform: Platform.operatingSystem,
      userType: _currentUserStorage?.currentUserData?.runtimeType,
    );
  }
}
