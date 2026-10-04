// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';

const loadingPageRoute = '/';
const mainPageRoute = '/main';
const authPageRoute = '/auth';
const drawerRoutePrefix = 'drawer';

const settingsPath = 'settings';
const aboutPath = 'about';
const supportPath = 'support';

String mainPageTabLocation(String pagePath) => '$mainPageRoute/$pagePath';

String mainPageDestinationLocation(String pagePath) =>
    MainPageRouting.navbarRoutes.any((route) => route.pagePath == pagePath)
        ? mainPageTabLocation(pagePath)
        : '$mainPageRoute/more/$drawerRoutePrefix/$pagePath';

String? mainPageDestinationPath(Uri uri) {
  final segments = uri.pathSegments;
  if (segments.isEmpty || '/${segments.first}' != mainPageRoute) {
    return null;
  }
  final drawerIndex = segments.indexOf(drawerRoutePrefix);
  final index = drawerIndex < 0 ? 1 : drawerIndex + 1;
  return index < segments.length ? segments[index] : null;
}
