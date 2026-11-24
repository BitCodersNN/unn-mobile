// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/core/models/schedule/subject_type.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/mini_preview_primitives.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/slot_highlight.dart';

class ScheduleMiniScreenBody extends StatelessWidget {
  final PaletteColorSlot selectedSlot;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const ScheduleMiniScreenBody({
    required this.selectedSlot,
    required this.onSlotSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final extra = theme.unnMobileColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: extra?.scheduleDayHighlight ?? colors.surfaceContainer,
                borderRadius: BorderRadius.circular(
                  MiniPreviewStyle.smallRadius,
                ),
              ),
              child: HighlightedSlotText(
                text: 'Понедельник · 23 ноября',
                slot: PaletteColorSlot.onSurface,
                selectedSlot: selectedSlot,
                onSlotSelected: onSlotSelected,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: MiniPreviewStyle.fontSizeBody,
                ),
              ),
            ),
            const SizedBox(height: 6),
            MiniLessonTile(
              title: 'Математический анализ',
              subtitle: '09:00–10:30 · Ауд. 214',
              backgroundColor:
                  extra?.scheduleSubjectHighlight ?? theme.cardColor,
              barColor: theme.getColorOfSubjectType(SubjectType.lecture),
            ),
            const SizedBox(height: 5),
            SlotHighlight(
              active: selectedSlot == PaletteColorSlot.cardSurface,
              borderRadius: BorderRadius.circular(
                MiniPreviewStyle.mediumRadius,
              ),
              onTap: () => onSlotSelected(PaletteColorSlot.cardSurface),
              child: MiniLessonTile(
                title: 'Дискретная математика',
                subtitle: '10:40–12:10 · Ауд. 305',
                backgroundColor: theme.cardColor,
                barColor: theme.getColorOfSubjectType(SubjectType.practice),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
