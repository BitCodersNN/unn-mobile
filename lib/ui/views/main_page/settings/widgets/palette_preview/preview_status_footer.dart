// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/mini_preview_primitives.dart';

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
    final safePage = pageCount > 0 ? currentPage.clamp(0, pageCount - 1) : 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant.withValues(
              alpha: MiniPreviewStyle.footerBorderAlpha,
            ),
          ),
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
                  color: colors.outlineVariant.withValues(
                    alpha: MiniPreviewStyle.dotBorderAlpha,
                  ),
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
                      onTap: () => onPageTap?.call(i),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: MiniPreviewStyle.animationDuration,
                        width: i == safePage ? 14 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: i == safePage
                              ? colors.primary
                              : colors.outlineVariant.withValues(
                                  alpha: MiniPreviewStyle.dotInactiveAlpha,
                                ),
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
