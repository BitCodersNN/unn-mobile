// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

// context_menu_action.dart

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_action.dart';

class ContextMenuHelper {
  static void showContextMenu({
    required BuildContext context,
    required dynamic model,
    required List<ContextMenuAction> Function() actionsBuilder,
    VoidCallback? onOpen,
    VoidCallback? onClose,
  }) {
    triggerHaptic(HapticIntensity.medium);
    final renderBox = context.findRenderObject()! as RenderBox;

    final actions = actionsBuilder();

    ContextMenuHelper.show(
      context: context,
      renderBox: renderBox,
      actions: actions,
      onOpen: onOpen,
      onClose: onClose,
    );
  }

  static Future<void> show({
    required BuildContext context,
    required RenderBox renderBox,
    required List<ContextMenuAction> actions,
    VoidCallback? onOpen,
    VoidCallback? onClose,
  }) async {
    triggerHaptic(HapticIntensity.medium);
    onOpen?.call();

    final wrappedEntries = <PopupMenuEntry<void>>[
      for (final action in actions) _wrapAction(context, action),
    ];

    final offset = renderBox.localToGlobal(Offset.zero);
    final position = RelativeRect.fromLTRB(
      offset.dx,
      offset.dy + renderBox.size.height,
      offset.dx + renderBox.size.width,
      offset.dy + renderBox.size.height + 1,
    );

    await showMenu<void>(
      context: context,
      position: position,
      items: wrappedEntries,
    );

    onClose?.call();
  }

  static PopupMenuEntry<void> _wrapAction(
    BuildContext context,
    ContextMenuAction action,
  ) {
    final entry = action.entry;

    if (entry is PopupMenuItem<void> && entry.enabled) {
      return PopupMenuItem<void>(
        child: entry.child,
        onTap: () {
          action.onTap?.call();
        },
      );
    }
    return entry;
  }
}
