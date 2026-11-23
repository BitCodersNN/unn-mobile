// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

class CenteredStageScroll extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBackgroundTap;

  const CenteredStageScroll({
    required this.child,
    this.onBackgroundTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onBackgroundTap,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: child),
        ),
      ),
    ),
  );
}

class PreviewStatusFooter extends StatelessWidget {
  final String slotLabel;
  final Color slotColor;
  final String? pageTitle;
  final int pageCount;
  final int currentPage;
  final ValueChanged<int>? onPageTap;

  const PreviewStatusFooter({
    required this.slotLabel,
    required this.slotColor,
    this.pageTitle,
    this.pageCount = 0,
    this.currentPage = 0,
    this.onPageTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: slotColor,
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Элемент: $slotLabel',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (pageCount > 1 && pageTitle != null) ...[
              const SizedBox(width: 8),
              Text(
                pageTitle!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < pageCount; i++) ...[
                    if (i > 0) const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onPageTap != null ? () => onPageTap!(i) : null,
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: i == currentPage ? 14 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: i == currentPage
                              ? colors.primary
                              : colors.outlineVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SlotHighlight extends StatelessWidget {
  final bool active;
  final Widget child;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  const SlotHighlight({
    required this.active,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
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
