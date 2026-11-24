// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/mini_preview_primitives.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/slot_highlight.dart';

class FeedMiniScreenBody extends StatelessWidget {
  final PaletteColorSlot selectedSlot;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const FeedMiniScreenBody({
    required this.selectedSlot,
    required this.onSlotSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final importantColor =
        theme.unnMobileColors?.importantPostHighlight ?? colors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SlotHighlight(
              active: selectedSlot == PaletteColorSlot.importantPostHighlight,
              borderRadius: BorderRadius.circular(MiniPreviewStyle.cardRadius),
              onTap: () =>
                  onSlotSelected(PaletteColorSlot.importantPostHighlight),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(
                    MiniPreviewStyle.cardRadius,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.alphaBlend(
                        importantColor.withValues(alpha: isDark ? 0.18 : 0.07),
                        theme.cardColor,
                      ),
                      Color.alphaBlend(
                        importantColor.withValues(alpha: isDark ? 0.04 : 0),
                        theme.cardColor,
                      ),
                    ],
                  ),
                  border: Border.all(
                    color: importantColor.withValues(
                      alpha: isDark ? 0.48 : 0.2,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: importantColor.withValues(
                              alpha: isDark ? 0.22 : 0.12,
                            ),
                          ),
                          child: Icon(
                            Icons.campaign_rounded,
                            size: 12,
                            color: importantColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Деканат ИИТММ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: MiniPreviewStyle.fontSizeTitle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: importantColor.withValues(
                              alpha: isDark ? 0.22 : 0.1,
                            ),
                            borderRadius: BorderRadius.circular(
                              MiniPreviewStyle.mediumRadius,
                            ),
                          ),
                          child: Text(
                            'Важное',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: importantColor,
                              fontWeight: FontWeight.w700,
                              fontSize: MiniPreviewStyle.fontSizeMicro,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Открыта регистрация на олимпиаду.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface,
                        fontSize: MiniPreviewStyle.fontSizeBody,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            SlotHighlight(
              active: selectedSlot == PaletteColorSlot.cardSurface,
              borderRadius: BorderRadius.circular(MiniPreviewStyle.cardRadius),
              onTap: () => onSlotSelected(PaletteColorSlot.cardSurface),
              child: MiniSurfaceCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primaryContainer,
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            size: 13,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HighlightedSlotText(
                                text: 'Иван Петров',
                                slot: PaletteColorSlot.onSurface,
                                selectedSlot: selectedSlot,
                                onSlotSelected: onSlotSelected,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: MiniPreviewStyle.fontSizeTitle,
                                ),
                              ),
                              HighlightedSlotText(
                                text: '10 мин назад',
                                slot: PaletteColorSlot.onSurfaceVariant,
                                selectedSlot: selectedSlot,
                                onSlotSelected: onSlotSelected,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontSize: MiniPreviewStyle.fontSizeCaption,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Подробности уже доступны на портале.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface,
                        fontSize: MiniPreviewStyle.fontSizeBody,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    HighlightedSlotDivider(
                      selectedSlot: selectedSlot,
                      onSlotSelected: onSlotSelected,
                      innerPadding: const EdgeInsets.symmetric(vertical: 2),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(
                              MiniPreviewStyle.compactRadius,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite_border_rounded,
                                size: 11,
                                color: colors.onSecondaryContainer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '12',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                  fontSize: MiniPreviewStyle.fontSizeSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        SlotHighlight(
                          active: selectedSlot == PaletteColorSlot.secondary,
                          borderRadius: BorderRadius.circular(
                            MiniPreviewStyle.compactRadius,
                          ),
                          onTap: () =>
                              onSlotSelected(PaletteColorSlot.secondary),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: colors.secondary.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(
                                MiniPreviewStyle.compactRadius,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 10.5,
                                  color: colors.secondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '4',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colors.secondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: MiniPreviewStyle.fontSizeSmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
