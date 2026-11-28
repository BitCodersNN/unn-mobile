// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveDialogAction extends StatelessWidget {
  const AdaptiveDialogAction({
    required this.onPressed,
    required this.child,
    this.isDefaultAction = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool isDefaultAction;

  @override
  Widget build(BuildContext context) => switch (Theme.of(context).platform) {
    TargetPlatform.iOS || TargetPlatform.macOS => CupertinoDialogAction(
      onPressed: onPressed,
      isDefaultAction: isDefaultAction,
      child: child,
    ),
    _ =>
      isDefaultAction
          ? FilledButton(onPressed: onPressed, child: child)
          : TextButton(onPressed: onPressed, child: child),
  };
}
