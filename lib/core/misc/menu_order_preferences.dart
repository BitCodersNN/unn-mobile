// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/tab_bar_preferences.dart';

class MenuOrderPreferences {
  static List<String> orderedPaths(
    Iterable<String> available,
    Iterable<String> saved,
  ) {
    final remaining = available.toSet();
    return List.unmodifiable([
      for (final path in saved)
        if (remaining.remove(path)) path,
      ...remaining,
    ]);
  }

  static List<String> reorder({
    required Iterable<String> saved,
    required Iterable<String> available,
    required List<String> visible,
    required int from,
    required int to,
  }) {
    final reordered = TabBarPreferences.reordered(visible, from, to).iterator;
    final visiblePaths = visible.toSet();
    final allPaths = {...saved, ...available};
    return List.unmodifiable([
      for (final path in allPaths)
        if (visiblePaths.contains(path) && reordered.moveNext())
          reordered.current
        else
          path,
    ]);
  }
}
