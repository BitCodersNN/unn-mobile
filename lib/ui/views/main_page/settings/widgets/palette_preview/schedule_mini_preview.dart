// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/mini_preview_primitives.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/schedule_preview_samples.dart';
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
    final first = schedulePreviewSamples[0];
    final second = schedulePreviewSamples[1];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MiniDayHeader(
              dayName: 'ПОНЕДЕЛЬНИК',
              dateLabel: '23 ноября',
              isToday: true,
              selectedSlot: selectedSlot,
              onSlotSelected: onSlotSelected,
            ),
            const SizedBox(height: 6),
            MiniLessonTile(
              title: first.title,
              subtitle: first.compactScheduleSubtitle,
              backgroundColor: theme.alternatingSurfaceColor,
              barColor: theme.getColorOfSubjectType(first.type),
            ),
            const SizedBox(height: 5),
            SlotHighlight(
              active: selectedSlot == PaletteColorSlot.cardSurface,
              borderRadius: BorderRadius.circular(
                MiniPreviewStyle.mediumRadius,
              ),
              onTap: () => onSlotSelected(PaletteColorSlot.cardSurface),
              child: MiniLessonTile(
                title: second.title,
                subtitle: second.compactScheduleSubtitle,
                backgroundColor: theme.cardColor,
                barColor: theme.getColorOfSubjectType(second.type),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
