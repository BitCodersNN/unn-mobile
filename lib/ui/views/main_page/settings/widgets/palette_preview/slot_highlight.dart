// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/mini_preview_primitives.dart';

class SlotHighlight extends StatelessWidget {
  final bool active;
  final Widget child;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  const SlotHighlight({
    required this.active,
    required this.child,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(MiniPreviewStyle.mediumRadius),
    ),
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final content = AnimatedContainer(
      duration: MiniPreviewStyle.animationDuration,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: active
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 0.5,
                ),
              ]
            : null,
      ),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: active ? primary.withValues(alpha: 0.08) : null,
          border: active
              ? Border.all(color: primary.withValues(alpha: 0.85), width: 1.5)
              : null,
        ),
        child: child,
      ),
    );
    if (onTap == null) {
      return content;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: content,
    );
  }
}
