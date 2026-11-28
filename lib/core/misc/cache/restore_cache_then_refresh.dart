// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

/// Показывает кэш до обновления, если запрос ещё актуален.
Future<void> restoreCacheThenRefresh<T>({
  required Future<T?> Function() readCache,
  required void Function(T data) restore,
  required FutureOr<void> Function() refresh,
  required bool Function() isCurrent,
}) async {
  final cached = await readCache();
  if (!isCurrent()) {
    return;
  }
  if (cached != null) {
    restore(cached);
  }
  await refresh();
}
