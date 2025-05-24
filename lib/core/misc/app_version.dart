// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:package_info_plus/package_info_plus.dart';

Future<String> getAppVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}
