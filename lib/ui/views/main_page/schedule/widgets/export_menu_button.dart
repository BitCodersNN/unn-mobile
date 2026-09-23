// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

class ExportMenuButton extends StatelessWidget {
  final bool enabled;
  final ValueChanged<String> onSelected;

  const ExportMenuButton({
    required this.enabled,
    required this.onSelected,
    super.key,
  });

  PopupMenuItem<String> _item({
    required String value,
    required IconData icon,
    required String title,
    required ThemeData theme,
    String? subtitle,
  }) =>
      PopupMenuItem<String>(
        value: value,
        enabled: enabled,
        height: subtitle == null ? 48 : 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.38,
          child: Row(
            children: [
              Icon(icon, size: 24, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  List<PopupMenuEntry<String>> _items(ThemeData theme) => [
        PopupMenuItem<String>(
          enabled: false,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              'Экспорт расписания',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const PopupMenuDivider(height: 9),
        _item(
          value: 'calendar',
          icon: Icons.calendar_month,
          title: 'Экспорт в календарь',
          theme: theme,
        ),
      ];

  Future<void> _showMenu(BuildContext buttonContext) async {
    final renderBox = buttonContext.findRenderObject()! as RenderBox;
    final buttonRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
    final screenSize = MediaQuery.of(buttonContext).size;
    final theme = Theme.of(buttonContext);

    const menuWidth = 300.0;
    final menuRight = buttonRect.right.clamp(12.0, screenSize.width - 12.0);
    final menuLeft = menuRight - menuWidth;
    final menuTop =
        (buttonRect.bottom + 4.0).clamp(12.0, screenSize.height - 12.0);
    final anchorFraction =
        ((buttonRect.center.dx - menuLeft) / menuWidth).clamp(0.0, 1.0);

    final value = await showGeneralDialog<String>(
      context: buttonContext,
      barrierDismissible: true,
      barrierLabel:
          MaterialLocalizations.of(buttonContext).modalBarrierDismissLabel,
      barrierColor: Colors.black.withAlpha(80),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) => Stack(
        children: [
          Positioned(
            top: menuTop,
            right: screenSize.width - menuRight,
            width: menuWidth,
            child: FadeTransition(
              opacity:
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: ScaleTransition(
                scale:
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                alignment: Alignment(anchorFraction * 2 - 1, -1.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: screenSize.height - menuTop - 8.0,
                  ),
                  child: SingleChildScrollView(
                    child: Material(
                      color: theme.colorScheme.surface,
                      elevation: 6,
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _items(theme),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (value != null) {
      onSelected(value);
    }
  }

  @override
  Widget build(BuildContext context) => Builder(
        builder: (buttonContext) => IconButton(
          icon: const Icon(Icons.more_vert),
          tooltip: 'Экспорт расписания',
          onPressed: () => _showMenu(buttonContext),
        ),
      );
}
