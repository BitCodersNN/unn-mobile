// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/tab_bar_preferences.dart';

const loadingPageRoute = '/';
const mainPageRoute = '/main';
const authPageRoute = '/auth';

const settingsPath = 'settings';
const aboutPath = 'about';
const supportPath = 'support';

String mainPageTabLocation(String pagePath) => '$mainPageRoute/$pagePath';

String mainPageDestinationLocation(
  String pagePath, {
  required List<String> tabPaths,
}) {
  final paths = tabPaths;
  final destination = pagePath.split('/').first;
  return paths.contains(destination)
      ? mainPageTabLocation(pagePath)
      : '$mainPageRoute/${TabBarPreferences.morePath}/$pagePath';
}

String? mainPageDestinationPath(Uri uri) {
  final segments = uri.pathSegments;
  if (segments.length < 2 || '/${segments.first}' != mainPageRoute) {
    return null;
  }
  return segments[1] == TabBarPreferences.morePath && segments.length > 2
      ? segments[2]
      : segments[1];
}
