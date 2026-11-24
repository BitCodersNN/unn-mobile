// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/ui/theme/palette_slot_labels.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/centered_stage_scroll.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/mini_preview_primitives.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/paged_category_preview.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/schedule_preview_samples.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/slot_highlight.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/widget_mini_preview.dart';

class ScheduleCategoryPreview extends StatelessWidget {
  final PaletteColorSlot selectedSlot;
  final Color selectedSlotColor;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const ScheduleCategoryPreview({
    required this.selectedSlot,
    required this.selectedSlotColor,
    required this.onSlotSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) => PagedCategoryPreview(
    slotLabel: selectedSlot.label,
    slotColor: selectedSlotColor,
    pages: [
      PreviewPage(
        title: 'Расписание',
        child: CenteredStageScroll(
          child: _ScheduleOverviewPage(
            selectedSlot: selectedSlot,
            onSlotSelected: onSlotSelected,
          ),
        ),
      ),
      PreviewPage(
        title: 'Виджет',
        child: WidgetMiniScreenPreview(
          selectedSlot: selectedSlot,
          onSlotSelected: onSlotSelected,
        ),
      ),
    ],
  );
}

class _ScheduleOverviewPage extends StatelessWidget {
  final PaletteColorSlot selectedSlot;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const _ScheduleOverviewPage({
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final activeEntry = schedulePreviewSamples.firstWhere(
      (entry) => entry.slot == selectedSlot,
      orElse: () => schedulePreviewSamples.first,
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MiniDayHeader(
            dayName: 'ПОНЕДЕЛЬНИК',
            dateLabel: '23 ноября',
            fontSize: MiniPreviewStyle.fontSizeTitle,
          ),
          const SizedBox(height: 8),
          MiniLessonTile(
            title: activeEntry.title,
            subtitle: activeEntry.scheduleSubtitle,
            backgroundColor: theme.alternatingSurfaceColor,
            barColor: theme.getColorOfSubjectType(activeEntry.type),
            borderRadius: MiniPreviewStyle.compactRadius,
            borderAlpha: MiniPreviewStyle.subtleBorderAlpha,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            barWidth: 4,
            barHeight: 26,
            titleStyle: theme.textTheme.labelLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
            subtitleStyle: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final entry in schedulePreviewSamples)
                Builder(
                  builder: (context) {
                    final chipColor = theme.getColorOfSubjectType(entry.type);
                    return SlotHighlight(
                      active: selectedSlot == entry.slot,
                      borderRadius: BorderRadius.circular(
                        MiniPreviewStyle.mediumRadius,
                      ),
                      onTap: () => onSlotSelected(entry.slot),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: chipColor.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(
                            MiniPreviewStyle.mediumRadius,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: chipColor,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              entry.slot.label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
