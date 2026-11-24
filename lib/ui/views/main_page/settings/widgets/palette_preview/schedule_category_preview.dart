// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/core/models/schedule/subject_type.dart';
import 'package:unn_mobile/ui/theme/palette_slot_labels.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/centered_stage_scroll.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/mini_preview_primitives.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/paged_category_preview.dart';
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
          onBackgroundTap: () => onSlotSelected(PaletteColorSlot.surface),
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
  static const _subjectEntries = [
    (SubjectType.lecture, 'Лекция', PaletteColorSlot.subjectLecture),
    (SubjectType.practice, 'Практика', PaletteColorSlot.subjectPractice),
    (SubjectType.lab, 'Лабораторная', PaletteColorSlot.subjectLab),
    (SubjectType.exam, 'Экзамен', PaletteColorSlot.subjectExam),
    (SubjectType.consult, 'Консультация', PaletteColorSlot.subjectConsult),
    (SubjectType.unknown, 'Другое', PaletteColorSlot.subjectUnknown),
  ];

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
    final extra = theme.unnMobileColors;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SlotHighlight(
            active: selectedSlot == PaletteColorSlot.scheduleDayHighlight,
            borderRadius: BorderRadius.circular(MiniPreviewStyle.compactRadius),
            onTap: () => onSlotSelected(PaletteColorSlot.scheduleDayHighlight),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: extra?.scheduleDayHighlight ?? colors.surfaceContainer,
                borderRadius: BorderRadius.circular(
                  MiniPreviewStyle.compactRadius,
                ),
              ),
              child: Text(
                'Понедельник · Сегодня',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SlotHighlight(
            active: selectedSlot == PaletteColorSlot.scheduleSubjectHighlight,
            borderRadius: BorderRadius.circular(MiniPreviewStyle.compactRadius),
            onTap: () =>
                onSlotSelected(PaletteColorSlot.scheduleSubjectHighlight),
            child: MiniLessonTile(
              title: 'Математический анализ',
              subtitle: '09:00–10:30 · Ауд. 214 (текущая пара)',
              backgroundColor:
                  extra?.scheduleSubjectHighlight ?? theme.cardColor,
              barColor: theme.getColorOfSubjectType(SubjectType.lecture),
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
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final entry in _subjectEntries)
                SlotHighlight(
                  active: selectedSlot == entry.$3,
                  borderRadius: BorderRadius.circular(
                    MiniPreviewStyle.mediumRadius,
                  ),
                  onTap: () => onSlotSelected(entry.$3),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme
                          .getColorOfSubjectType(entry.$1)
                          .withValues(alpha: 0.16),
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
                            color: theme.getColorOfSubjectType(entry.$1),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          entry.$2,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w500,
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
    );
  }
}
