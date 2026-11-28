// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

sealed class AppMenuEntry {
  const AppMenuEntry();
}

final class AppMenuAction extends AppMenuEntry {
  final String title;
  final IconData? icon;
  final Widget? leading;
  final VoidCallback onSelected;
  final bool enabled;
  final bool isDestructive;

  const AppMenuAction({
    required this.title,
    required this.onSelected,
    this.icon,
    this.leading,
    this.enabled = true,
    this.isDestructive = false,
  }) : assert(
         icon == null || leading == null,
         'Specify either icon or leading, not both.',
       );
}

final class AppMenuDivider extends AppMenuEntry {
  const AppMenuDivider();
}

class MenuButton extends StatelessWidget {
  final List<AppMenuEntry> entries;
  final IconData icon;
  final Color? iconColor;
  final String tooltip;
  final String? sheetTitle;

  const MenuButton({
    required this.entries,
    this.icon = Icons.more_vert,
    this.iconColor,
    this.tooltip = 'Меню',
    this.sheetTitle,
    super.key,
  });

  Future<void> _showCupertinoSheet(BuildContext context) async {
    final actions = entries.whereType<AppMenuAction>().toList();
    final selected = await showCupertinoModalPopup<AppMenuAction>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: sheetTitle != null ? Text(sheetTitle!) : null,
        actions: [
          for (final action in actions)
            CupertinoActionSheetAction(
              isDestructiveAction: action.isDestructive,
              onPressed: action.enabled
                  ? () => Navigator.of(sheetContext).pop(action)
                  : () {},
              child: _CupertinoMenuActionContent(action: action),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: const Text('Отмена'),
        ),
      ),
    );
    if (selected != null) {
      selected.onSelected();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isApple = switch (theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };

    if (isApple) {
      return IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: iconColor),
        onPressed: () => unawaited(_showCupertinoSheet(context)),
      );
    }

    final hasAnyLeading = entries.whereType<AppMenuAction>().any(
      (action) => action.icon != null || action.leading != null,
    );

    return PopupMenuButton<AppMenuAction>(
      tooltip: tooltip,
      position: PopupMenuPosition.under,
      color: colors.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Icon(icon, color: iconColor),
      onSelected: (action) => action.onSelected(),
      itemBuilder: (context) => [
        for (final entry in entries)
          switch (entry) {
            AppMenuDivider() => const PopupMenuDivider(),
            final AppMenuAction action => PopupMenuItem<AppMenuAction>(
              value: action,
              enabled: action.enabled,
              child: _MaterialMenuActionRow(
                action: action,
                reserveLeadingSpace: hasAnyLeading,
              ),
            ),
          },
      ],
    );
  }
}

class _CupertinoMenuActionContent extends StatelessWidget {
  final AppMenuAction action;

  const _CupertinoMenuActionContent({required this.action});

  @override
  Widget build(BuildContext context) {
    final label = Text(action.title);

    final content = action.leading == null
        ? label
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              action.leading!,
              const SizedBox(width: 8),
              Flexible(child: label),
            ],
          );

    if (action.enabled) {
      return content;
    }

    return Opacity(opacity: 0.38, child: content);
  }
}

class _MaterialMenuActionRow extends StatelessWidget {
  final AppMenuAction action;
  final bool reserveLeadingSpace;

  const _MaterialMenuActionRow({
    required this.action,
    required this.reserveLeadingSpace,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foregroundColor = action.isDestructive
        ? colors.error
        : colors.onSurface;
    final leadingIconColor = action.isDestructive
        ? colors.error
        : colors.primary;

    Widget? leadingWidget;
    if (action.leading != null) {
      leadingWidget = action.leading;
    } else if (action.icon != null) {
      leadingWidget = Icon(action.icon, size: 20, color: leadingIconColor);
    }

    return Opacity(
      opacity: action.enabled ? 1 : 0.38,
      child: Row(
        children: [
          if (reserveLeadingSpace) ...[
            SizedBox(
              width: 20,
              child: Center(child: leadingWidget ?? const SizedBox.shrink()),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Text(
              action.title,
              style: (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
                color: foregroundColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
