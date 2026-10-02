// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';

class SideMenuItem {
  final String value;
  final String title;
  final String? subtitle;

  const SideMenuItem({
    required this.value,
    required this.title,
    this.subtitle,
  });
}

class SideMenuItemWithIcon extends SideMenuItem {
  final IconData icon;
  const SideMenuItemWithIcon({
    required this.icon,
    required super.value,
    required super.title,
  });
}

class CheckedSideMenuItem extends SideMenuItem {
  final bool Function()? getValue;
  // Для колбэков именованные параметры излишни
  // ignore: avoid_positional_boolean_parameters
  final FutureOr<void> Function(bool)? updateValue;

  CheckedSideMenuItem({
    required super.value,
    required super.title,
    this.getValue,
    this.updateValue,
  });
}

class MenuButton extends StatelessWidget {
  final bool enabled;
  final List<SideMenuItem> items;
  final ValueChanged<String> onSelected;

  const MenuButton({
    required this.items,
    required this.onSelected,
    this.enabled = true,
    super.key,
  });

  List<Widget> _items(BuildContext context) {
    final needsShift =
        items.any((e) => e is SideMenuItemWithIcon || e is CheckedSideMenuItem);
    return items
        .map(
          (e) => _MenuItemView(
            data: e,
            enabled: enabled,
            shiftNonIconItems: needsShift,
          ),
        )
        .toList();
  }

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
                        children: _items(context),
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
          tooltip: 'Меню',
          onPressed: () => _showMenu(buttonContext),
        ),
      );
}

class _MenuItemView extends StatefulWidget {
  const _MenuItemView({
    required this.data,
    required this.enabled,
    required this.shiftNonIconItems,
  });

  final SideMenuItem data;
  final bool enabled;
  final bool shiftNonIconItems;

  @override
  State<_MenuItemView> createState() => _MenuItemViewState();
}

class _MenuItemViewState extends State<_MenuItemView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuItem<String>(
      value: widget.data.value,
      enabled: widget.enabled,
      height: widget.data.subtitle == null ? 48 : 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Opacity(
        opacity: widget.enabled ? 1.0 : 0.38,
        child: Row(
          children: [
            _getIcon(context, widget.data),
            if (widget.shiftNonIconItems) const SizedBox(width: 18),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.data.title,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.data.subtitle != null)
                    Text(
                      widget.data.subtitle!,
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
  }

  Widget _getIcon(BuildContext context, SideMenuItem data) {
    final theme = Theme.of(context);
    final iconSize = 24.0;

    if (data is SideMenuItemWithIcon) {
      return Icon(data.icon, size: iconSize, color: theme.colorScheme.primary);
    }
    if (data is CheckedSideMenuItem) {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: Center(
          child: Checkbox(
            shape: const CircleBorder(),
            value: data.getValue?.call() ?? false,
            onChanged: (v) async {
              if (v != null) {
                final task = data.updateValue?.call(v);
                setState(() {});
                await task;
                if (context.mounted) {
                  setState(() {});
                }
              }
            },
            semanticLabel: '${data.title}\n${data.subtitle ?? ''}',
          ),
        ),
      );
    }
    if (widget.shiftNonIconItems) {
      return SizedBox(width: iconSize, height: iconSize);
    }
    return Container();
  }
}
