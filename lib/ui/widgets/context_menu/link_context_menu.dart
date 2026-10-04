import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/ui/widgets/anchored_popup.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_action.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_actions.dart';
import 'package:unn_mobile/ui/widgets/context_menu/link_context_menu_actions.dart';
import 'package:unn_mobile/ui/widgets/context_menu/link_preview.dart';

class LinkContextMenu extends StatefulWidget {
  final String url;
  final String label;
  final VoidCallback onOpen;
  final Widget child;

  const LinkContextMenu({
    required this.url,
    required this.label,
    required this.onOpen,
    required this.child,
    super.key,
  });

  @override
  State<LinkContextMenu> createState() => _LinkContextMenuState();
}

class _LinkContextMenuState extends State<LinkContextMenu> {
  bool _menuOpen = false;

  Future<void> _showMenu() async {
    if (_menuOpen) {
      return;
    }
    _menuOpen = true;
    try {
      final actions = createLinkActions(
        context: context,
        url: widget.url,
        onOpen: widget.onOpen,
      );
      final action = await showAnchoredPopup<ContextMenuAction>(
        context,
        width: 360,
        gap: 10,
        placement: AnchoredPopupPlacement.below,
        alignment: AnchoredPopupAlignment.start,
        blurSigma: 3,
        barrierOpacity: 0.1,
        builder: (context) => ContextMenuActions(
          key: const ValueKey('link-menu-card'),
          elevation: 8,
          actions: actions,
          onSelected: (action) => dismissAnchoredPopup(
            context,
            action,
            hapticIntensity: HapticIntensity.light,
          ),
          header: LinkPreview(url: widget.url, label: widget.label),
        ),
      );
      if (mounted) {
        action?.onTap?.call();
      }
    } finally {
      _menuOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          triggerHaptic(HapticIntensity.light);
          widget.onOpen();
        },
        onLongPress: _showMenu,
        child: widget.child,
      );
}
