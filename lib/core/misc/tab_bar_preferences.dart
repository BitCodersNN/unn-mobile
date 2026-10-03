// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

class TabBarPreferences {
  static const defaultPaths = [
    'feed',
    'schedule',
    'chats',
    'source',
    'more',
  ];
  static const availablePaths = [
    ...defaultPaths,
    'grades',
    'online_certificates',
    'settings',
    'donations',
    'about',
  ];

  static List<String> normalize(
    Iterable<String> paths, {
    Iterable<String> allowed = availablePaths,
  }) {
    final result = paths
        .where((path) => path != 'more' && allowed.contains(path))
        .toSet()
        .take(4)
        .toList();
    for (final path in defaultPaths) {
      if (result.length >= 2) {
        break;
      }
      if (path != 'more' && allowed.contains(path) && !result.contains(path)) {
        result.add(path);
      }
    }
    result.add('more');
    return List.unmodifiable(result);
  }
}
