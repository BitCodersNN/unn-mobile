// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_action.dart';

class ContextMenuHelper {
  static Future<void> showContextMenu({
    required BuildContext context,
    required List<ContextMenuAction> Function() actionsBuilder,
    VoidCallback? onOpen,
    VoidCallback? onClose,
  }) {
    final renderBox = context.findRenderObject();
    if (renderBox is! RenderBox || !renderBox.attached) {
      return Future<void>.value();
    }
    return show(
      context: context,
      renderBox: renderBox,
      actions: actionsBuilder(),
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

    final offset = renderBox.localToGlobal(Offset.zero);
    final position = RelativeRect.fromLTRB(
      offset.dx,
      offset.dy + renderBox.size.height,
      offset.dx + renderBox.size.width,
      offset.dy + renderBox.size.height + 1,
    );

    try {
      await showMenu<void>(
        context: context,
        position: position,
        items: [
          for (final action in actions)
            PopupMenuItem<void>(
              enabled: action.enabled,
              onTap: action.onTap,
              child: action.child,
            ),
        ],
      );
    } finally {
      onClose?.call();
    }
  }
}
