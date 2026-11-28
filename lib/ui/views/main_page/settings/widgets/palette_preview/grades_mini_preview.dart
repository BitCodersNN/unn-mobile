// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/core/models/grade_book/mark_type.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/mini_preview_primitives.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/slot_highlight.dart';

class GradesMiniScreenBody extends StatelessWidget {
  static const _rows = [
    ('Математический анализ', 'Экзамен', MarkType.excellent, 'Отлично'),
    ('Алгоритмы и структуры', 'Экзамен', MarkType.good, 'Хорошо'),
  ];

  final PaletteColorSlot selectedSlot;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const GradesMiniScreenBody({
    required this.selectedSlot,
    required this.onSlotSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final summaryEndColor = Color.lerp(colors.primary, colors.secondary, 0.7)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SlotHighlight(
              active:
                  selectedSlot == PaletteColorSlot.primary ||
                  selectedSlot == PaletteColorSlot.secondary,
              borderRadius: BorderRadius.circular(MiniPreviewStyle.cardRadius),
              onTap: () => onSlotSelected(
                selectedSlot == PaletteColorSlot.primary
                    ? PaletteColorSlot.secondary
                    : PaletteColorSlot.primary,
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    MiniPreviewStyle.cardRadius,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.primary, summaryEndColor],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_stories_outlined,
                          size: 13,
                          color: colors.onPrimary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Семестр 3',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: MiniPreviewStyle.fontSizeTitle,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_up_rounded,
                          size: 15,
                          color: colors.onPrimary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniSummaryMetric(
                            label: 'Средний за семестр',
                            value: '4.67',
                            foreground: colors.onPrimary,
                            onTap: () =>
                                onSlotSelected(PaletteColorSlot.primary),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _MiniSummaryMetric(
                            label: 'За всё обучение',
                            value: '4.54',
                            foreground: colors.onPrimary,
                            onTap: () =>
                                onSlotSelected(PaletteColorSlot.secondary),
                          ),
                        ),
                      ],
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
                  children: [
                    for (var i = 0; i < _rows.length; i++) ...[
                      if (i > 0)
                        HighlightedSlotDivider(
                          selectedSlot: selectedSlot,
                          onSlotSelected: onSlotSelected,
                          outerPadding: const EdgeInsets.symmetric(vertical: 5),
                        ),
                      Builder(
                        builder: (context) {
                          final row = _rows[i];
                          final markColor = theme.getColorOfMarkType(row.$3);
                          return Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    HighlightedSlotText(
                                      text: row.$1,
                                      slot: PaletteColorSlot.onSurface,
                                      selectedSlot: selectedSlot,
                                      onSlotSelected: onSlotSelected,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: colors.onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    HighlightedSlotText(
                                      text: row.$2,
                                      slot: PaletteColorSlot.onSurfaceVariant,
                                      selectedSlot: selectedSlot,
                                      onSlotSelected: onSlotSelected,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: colors.onSurfaceVariant,
                                            fontSize:
                                                MiniPreviewStyle.fontSizeSmall,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              MiniMarkBadge(
                                label: row.$4,
                                color: markColor,
                                fontSize: MiniPreviewStyle.fontSizeBody,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
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

class _MiniSummaryMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color foreground;
  final VoidCallback onTap;

  const _MiniSummaryMetric({
    required this.label,
    required this.value,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: foreground.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground.withValues(alpha: 0.85),
                fontSize: MiniPreviewStyle.fontSizeMicro,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.labelLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
                fontSize: MiniPreviewStyle.fontSizeMetric,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
