import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_action.dart';

class ContextMenuActions extends StatelessWidget {
  final List<ContextMenuAction> actions;
  final ValueChanged<ContextMenuAction> onSelected;
  final Widget? header;
  final double elevation;

  const ContextMenuActions({
    required this.actions,
    required this.onSelected,
    this.header,
    this.elevation = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        elevation: elevation,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (header != null) header!,
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0 || header != null)
                  const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  minTileHeight: 52,
                  title: actions[i].child,
                  enabled: actions[i].enabled,
                  onTap:
                      actions[i].enabled ? () => onSelected(actions[i]) : null,
                ),
              ],
            ],
          ),
        ),
      );
}
