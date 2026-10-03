// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<bool?> showTabBarContextMenu(
  BuildContext context, {
  required IconData icon,
  required String label,
}) {
  final anchor = context.findRenderObject()! as RenderBox;
  final overlay = Navigator.of(context, rootNavigator: true)
      .overlay!
      .context
      .findRenderObject()! as RenderBox;
  final rect =
      anchor.localToGlobal(Offset.zero, ancestor: overlay) & anchor.size;
  return showGeneralDialog<bool>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 180),
    transitionBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
    pageBuilder: (context, animation, secondaryAnimation) =>
        _TabBarContextMenu(anchor: rect, icon: icon, label: label),
  );
}

class _TabBarContextMenu extends StatelessWidget {
  final Rect anchor;
  final IconData icon;
  final String label;

  const _TabBarContextMenu({
    required this.anchor,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final background = CupertinoDynamicColor.resolve(
      CupertinoColors.tertiarySystemBackground,
      context,
    );
    final foreground =
        CupertinoDynamicColor.resolve(CupertinoColors.label, context);
    return MediaQuery.withNoTextScaling(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final menuWidth = (constraints.maxWidth - 32).clamp(0.0, 280.0);
          final left = (anchor.right - menuWidth)
              .clamp(16.0, constraints.maxWidth - menuWidth - 16);
          const previewSize = 64.0;
          final previewLeft = (anchor.center.dx - previewSize / 2)
              .clamp(16.0, constraints.maxWidth - previewSize - 16);
          final previewTop = (anchor.center.dy - previewSize / 2).clamp(
            MediaQuery.paddingOf(context).top + 16,
            constraints.maxHeight -
                MediaQuery.paddingOf(context).bottom -
                previewSize,
          );
          final menuTop = previewTop - 96;
          return Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(false),
                    child:
                        ColoredBox(color: Colors.black.withValues(alpha: 0.2)),
                  ),
                ),
              ),
              Positioned(
                left: left,
                top: menuTop,
                width: menuWidth,
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ColoredBox(
                    color: background,
                    child: CupertinoContextMenuAction(
                      onPressed: () => Navigator.of(context).pop(true),
                      trailingIcon: CupertinoIcons.gear,
                      child: Text(
                        'Настроить нижнее меню',
                        style: TextStyle(color: foreground, fontSize: 17),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: previewLeft,
                top: previewTop,
                width: previewSize,
                height: previewSize,
                child: Semantics(
                  label: label,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            size: 24,
                            color: CupertinoDynamicColor.resolve(
                              CupertinoColors.secondaryLabel,
                              context,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 14,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: CupertinoDynamicColor.resolve(
                                    CupertinoColors.secondaryLabel,
                                    context,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
