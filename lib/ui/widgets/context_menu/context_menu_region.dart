// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/ui/widgets/anchored_popup.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_action.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_actions.dart';

class ContextMenuRegion extends StatefulWidget {
  final Widget child;
  final List<ContextMenuAction> Function(BuildContext context) actionsBuilder;
  final Widget? header;
  final VoidCallback? onTap;

  const ContextMenuRegion({
    required this.child,
    required this.actionsBuilder,
    this.header,
    this.onTap,
    super.key,
  });

  @override
  State<ContextMenuRegion> createState() => _ContextMenuRegionState();
}

class _ContextMenuRegionState extends State<ContextMenuRegion> {
  bool _menuOpen = false;

  Future<void> _showMenu() async {
    if (_menuOpen) {
      return;
    }
    _menuOpen = true;
    try {
      await _showMenuAndRunAction();
    } finally {
      _menuOpen = false;
    }
  }

  Future<void> _showMenuAndRunAction() async {
    final actions = widget.actionsBuilder(context);
    if (actions.isEmpty) {
      return;
    }
    final action = await showAnchoredPopup<ContextMenuAction>(
      context,
      width: 360,
      gap: 10,
      placement: AnchoredPopupPlacement.below,
      alignment: AnchoredPopupAlignment.start,
      blurSigma: 3,
      barrierOpacity: 0.1,
      builder: (context) => ContextMenuActions(
        elevation: 8,
        actions: actions,
        onSelected: (action) => dismissAnchoredPopup(
          context,
          action,
          hapticIntensity: HapticIntensity.light,
        ),
        header: widget.header,
      ),
    );
    if (mounted) {
      action?.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap == null
        ? null
        : () {
            triggerHaptic(HapticIntensity.light);
            widget.onTap!();
          },
    onLongPress: _showMenu,
    child: widget.child,
  );
}
