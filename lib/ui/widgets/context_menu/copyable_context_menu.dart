// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_action.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_region.dart';

class CopyableContextMenu extends StatelessWidget {
  final String label;
  final String value;
  final Widget child;
  final List<ContextMenuAction> actions;

  const CopyableContextMenu({
    required this.label,
    required this.value,
    required this.child,
    this.actions = const [],
    super.key,
  });

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) {
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(const SnackBar(content: Text('Скопировано')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) {
      return child;
    }
    final theme = Theme.of(context);
    return ContextMenuRegion(
      actionsBuilder: (context) => [
        ...actions,
        ContextMenuAction.text(
          label: 'Скопировать',
          leadingIcon: const Icon(Icons.copy_outlined, size: 18),
          onTap: () => _copy(context),
        ),
      ],
      header: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      child: child,
    );
  }
}
