// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/core/models/grade_book/mark_type.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/mini_preview_primitives.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/slot_highlight.dart';

class GradesCategoryPreview extends StatelessWidget {
  static const _gradeEntries = [
    (
      'Алгебра и геометрия',
      MarkType.excellent,
      'Отлично',
      PaletteColorSlot.markExcellent,
    ),
    (
      'Дискретная математика',
      MarkType.good,
      'Хорошо',
      PaletteColorSlot.markGood,
    ),
    (
      'Физика',
      MarkType.satisfactory,
      'Удовл.',
      PaletteColorSlot.markSatisfactory,
    ),
    (
      'Информатика',
      MarkType.notSatisfactory,
      'Неуд.',
      PaletteColorSlot.markUnsatisfactory,
    ),
    (
      'Иностранный язык',
      MarkType.credited,
      'Зачтено',
      PaletteColorSlot.markCredited,
    ),
    ('История', MarkType.noShow, 'Неявка', PaletteColorSlot.markNoShow),
  ];

  final PaletteColorSlot selectedSlot;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const GradesCategoryPreview({
    required this.selectedSlot,
    required this.onSlotSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: MiniSurfaceCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _gradeEntries.length; i++) ...[
              if (i > 0) const SizedBox(height: 4),
              Builder(
                builder: (context) {
                  final entry = _gradeEntries[i];
                  final markColor = theme.getColorOfMarkType(entry.$2);
                  return SlotHighlight(
                    active: selectedSlot == entry.$4,
                    borderRadius: BorderRadius.circular(
                      MiniPreviewStyle.smallRadius,
                    ),
                    onTap: () => onSlotSelected(entry.$4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.$1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          MiniMarkBadge(
                            label: entry.$3,
                            color: markColor,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
