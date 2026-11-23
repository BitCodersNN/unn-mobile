// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/core/models/grade_book/mark_type.dart';
import 'package:unn_mobile/core/models/schedule/subject_type.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/slot_highlight.dart';

class ScheduleCategoryPreview extends StatelessWidget {
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

  const ScheduleCategoryPreview({
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
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SlotHighlight(
            active: selectedSlot == PaletteColorSlot.scheduleDayHighlight,
            borderRadius: BorderRadius.circular(12),
            onTap: () => onSlotSelected(PaletteColorSlot.scheduleDayHighlight),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: extra?.scheduleDayHighlight ?? colors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
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
            borderRadius: BorderRadius.circular(12),
            onTap: () =>
                onSlotSelected(PaletteColorSlot.scheduleSubjectHighlight),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: extra?.scheduleSubjectHighlight ?? theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 26,
                    decoration: BoxDecoration(
                      color: theme.getColorOfSubjectType(SubjectType.lecture),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Математический анализ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '09:00–10:30 · Ауд. 214 (текущая пара)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                  borderRadius: BorderRadius.circular(10),
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
                      borderRadius: BorderRadius.circular(10),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
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
                    borderRadius: BorderRadius.circular(8),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: markColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              entry.$3,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: markColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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

class EffectsCategoryPreview extends StatelessWidget {
  final PaletteColorSlot selectedSlot;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const EffectsCategoryPreview({
    required this.selectedSlot,
    required this.onSlotSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final extra = theme.unnMobileColors!;
    final baseColor = extra.shimmerBaseColor;
    final highlightColor = extra.shimmerHighlightColor;
    final gradient = LinearGradient(
      colors: [baseColor, highlightColor, baseColor],
      stops: const [0.15, 0.5, 0.85],
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SlotHighlight(
              active:
                  selectedSlot == PaletteColorSlot.shimmerBase ||
                  selectedSlot == PaletteColorSlot.shimmerHighlight,
              borderRadius: BorderRadius.circular(10),
              onTap: () => onSlotSelected(PaletteColorSlot.shimmerBase),
              child: Container(
                height: 22,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SlotHighlight(
                  active: selectedSlot == PaletteColorSlot.shimmerBase,
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => onSlotSelected(PaletteColorSlot.shimmerBase),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: baseColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SlotHighlight(
                        active:
                            selectedSlot == PaletteColorSlot.shimmerHighlight,
                        borderRadius: BorderRadius.circular(6),
                        onTap: () =>
                            onSlotSelected(PaletteColorSlot.shimmerHighlight),
                        child: Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: highlightColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      FractionallySizedBox(
                        widthFactor: 0.65,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: gradient,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
