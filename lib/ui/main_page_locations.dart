// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/constants/main_page_paths.dart';

const loadingPageRoute = '/';
const mainPageRoute = '/main';
const authPageRoute = '/auth';

const settingsPath = MainPagePaths.settings;
const aboutPath = MainPagePaths.about;
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
      : '$mainPageRoute/${MainPagePaths.more}/$pagePath';
}

String? mainPageDestinationPath(Uri uri) {
  final segments = uri.pathSegments;
  if (segments.length < 2 || '/${segments.first}' != mainPageRoute) {
    return null;
  }
  return segments[1] == MainPagePaths.more && segments.length > 2
      ? segments[2]
      : segments[1];
}
