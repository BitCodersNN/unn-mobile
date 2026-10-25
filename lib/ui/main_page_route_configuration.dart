// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/constants/main_page_paths.dart';
import 'package:unn_mobile/core/misc/tab_bar_preferences.dart';
import 'package:unn_mobile/ui/main_page_locations.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_route_data.dart';

class MainPageRouteConfiguration {
  final List<String> paths;
  final List<MainPageRouteData> destinations;
  final List<MainPageRouteData> tabs;

  factory MainPageRouteConfiguration({
    required List<MainPageRouteData> routes,
    required Iterable<String> paths,
    Type? userType,
  }) {
    final available = routes
        .where(
          (route) =>
              !route.isDisabled &&
              (userType == null ||
                  route.userTypes.isEmpty ||
                  route.userTypes.contains(userType)),
        )
        .toList(growable: false);
    final byPath = {for (final route in available) route.pagePath: route};
    final selected = TabBarPreferences.normalize(paths, allowed: byPath.keys);
    final more = byPath[MainPagePaths.more]!;
    return MainPageRouteConfiguration._(
      selected,
      List.unmodifiable(available),
      List.unmodifiable([
        for (final path in selected)
          if (path == MainPagePaths.more)
            more.copyWith(
              subroutes: [
                ...more.subroutes,
                for (final route in available)
                  if (!selected.contains(route.pagePath)) route,
              ],
            )
          else
            byPath[path]!,
      ]),
    );
  }

  const MainPageRouteConfiguration._(this.paths, this.destinations, this.tabs);

  bool containsDestination(String path) =>
      destinations.any((route) => route.pagePath == path);

  String locationFor(String pagePath) =>
      mainPageDestinationLocation(pagePath, tabPaths: paths);

  Uri relocate(Uri uri) {
    final destination = mainPageDestinationPath(uri);
    if (destination == null) {
      return uri;
    }
    final index =
        uri.pathSegments[1] == MainPagePaths.more && uri.pathSegments.length > 2
            ? 2
            : 1;
    return Uri(
      pathSegments: [
        '',
        ...Uri.parse(locationFor(destination)).pathSegments,
        ...uri.pathSegments.skip(index + 1),
      ],
      query: uri.hasQuery ? uri.query : null,
      fragment: uri.hasFragment ? uri.fragment : null,
    );
  }
}
