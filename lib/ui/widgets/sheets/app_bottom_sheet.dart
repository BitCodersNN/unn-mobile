// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  double heightFactor = 0.94,
  Color? backgroundColor,
  BoxConstraints? constraints,
}) {
  assert(heightFactor > 0 && heightFactor <= 1);
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    enableDrag: true,
    backgroundColor: backgroundColor,
    constraints: constraints,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (context) => FractionallySizedBox(
      heightFactor: heightFactor,
      child: builder(context),
    ),
  );
}
