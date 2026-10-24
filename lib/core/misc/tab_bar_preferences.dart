// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/constants/main_page_paths.dart';

typedef TabBarPathsSaver = Future<void> Function(List<String> paths);

class TabBarPreferences {
  static const minTabs = 3;
  static const maxTabs = 5;
  static const editableSlotCount = maxTabs - 1;
  static const requiredSlotCount = minTabs - 1;

  static const defaultPaths = [
    MainPagePaths.feed,
    MainPagePaths.schedule,
    MainPagePaths.chats,
    MainPagePaths.source,
    MainPagePaths.more,
  ];

  static List<T> reordered<T>(Iterable<T> items, int from, int to) {
    final result = List<T>.of(items);
    final moved = result.removeAt(from);
    result.insert(to, moved);
    return List.unmodifiable(result);
  }

  static List<String> normalize(
    Iterable<String> paths, {
    Iterable<String>? allowed,
  }) {
    final allowedPaths = allowed?.toSet();
    final result = paths
        .where(
          (path) =>
              path.isNotEmpty &&
              !path.contains('/') &&
              path != MainPagePaths.more &&
              (allowedPaths == null || allowedPaths.contains(path)),
        )
        .toSet()
        .take(editableSlotCount)
        .toList();
    for (final path in {...defaultPaths, ...?allowedPaths}) {
      if (result.length >= requiredSlotCount) {
        break;
      }
      if (path != MainPagePaths.more &&
          (allowedPaths == null || allowedPaths.contains(path)) &&
          !result.contains(path)) {
        result.add(path);
      }
    }
    result.add(MainPagePaths.more);
    return List.unmodifiable(result);
  }
}
