import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar_item_content.dart';

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
    transitionBuilder: (context, animation, secondaryAnimation, child) => child,
    pageBuilder: (context, animation, secondaryAnimation) => _TabBarContextMenu(
      anchor: rect,
      icon: icon,
      label: label,
      animation: animation,
    ),
  );
}

class _TabBarContextMenu extends StatelessWidget {
  final Rect anchor;
  final IconData icon;
  final String label;
  final Animation<double> animation;

  const _TabBarContextMenu({
    required this.anchor,
    required this.icon,
    required this.label,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: animation,
        builder: (context, _) => _buildMenu(
          context,
          Curves.easeOutCubic.transform(animation.value),
        ),
      );

  Widget _buildMenu(BuildContext context, double progress) {
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
          final previewLeft = anchor.center.dx - previewSize / 2;
          final previewTop = anchor.center.dy - previewSize / 2;
          final menuTop = previewTop - 96;
          return Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5 * progress,
                    sigmaY: 5 * progress,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(false),
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.2 * progress),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: left,
                top: menuTop,
                width: menuWidth,
                height: 80,
                child: Opacity(
                  opacity: progress,
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
              ),
              Positioned(
                left: previewLeft,
                top: previewTop,
                width: previewSize,
                height: previewSize,
                child: Opacity(
                  opacity: progress,
                  child: Semantics(
                    label: label,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: TabBarItemContent(
                          icon: icon,
                          label: label,
                          color: CupertinoDynamicColor.resolve(
                            CupertinoColors.secondaryLabel,
                            context,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 10,
                            color: CupertinoDynamicColor.resolve(
                              CupertinoColors.secondaryLabel,
                              context,
                            ),
                          ),
                        ),
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
