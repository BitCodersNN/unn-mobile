// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';

class ContextMenuAction {
  final Widget child;
  final bool enabled;
  final VoidCallback? onTap;

  const ContextMenuAction({
    required this.child,
    this.enabled = true,
    this.onTap,
  });

  factory ContextMenuAction.text({
    required String label,
    VoidCallback? onTap,
    Widget? leadingIcon,
  }) =>
      ContextMenuAction(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              leadingIcon,
              const SizedBox(width: 12),
            ],
            Flexible(child: Text(label)),
          ],
        ),
        onTap: onTap,
      );

  factory ContextMenuAction.custom({
    required Widget child,
  }) =>
      ContextMenuAction(child: child, enabled: false);
}
