import 'package:flutter/material.dart';

class TabBarDragFeedback extends StatelessWidget {
  final bool dragging;
  final Color backgroundColor;
  final Widget child;

  const TabBarDragFeedback({
    required this.dragging,
    required this.backgroundColor,
    required this.child,
    super.key,
  });

  static Color highlightColor(BuildContext context, {double opacity = 1}) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08 * opacity);

  @override
  Widget build(BuildContext context) => AnimatedScale(
        scale: dragging ? 1.08 : 1,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: dragging
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: child,
        ),
      );
}
