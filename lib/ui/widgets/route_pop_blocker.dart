// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

class _RoutePopBlocker implements PopEntry<Object?> {
  @override
  final ValueNotifier<bool> canPopNotifier = ValueNotifier<bool>(false);

  @override
  void onPopInvoked(bool didPop) {}

  @override
  void onPopInvokedWithResult(bool didPop, Object? result) {}

  void dispose() => canPopNotifier.dispose();
}

Future<T> runWithBlockedRoutePop<T>(
  BuildContext context,
  Future<T> Function() action,
) async {
  final enclosingRoute = ModalRoute.of(context);
  final shellRoute = ModalRoute.of(Navigator.of(context).context);
  final popBlocker = _RoutePopBlocker();
  enclosingRoute?.registerPopEntry(popBlocker);
  if (shellRoute != enclosingRoute) {
    shellRoute?.registerPopEntry(popBlocker);
  }
  try {
    return await action();
  } finally {
    if (shellRoute != enclosingRoute) {
      shellRoute?.unregisterPopEntry(popBlocker);
    }
    enclosingRoute?.unregisterPopEntry(popBlocker);
    popBlocker.dispose();
  }
}
