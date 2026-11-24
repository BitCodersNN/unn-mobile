// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/centered_stage_scroll.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/mini_preview_primitives.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/schedule_preview_samples.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/slot_highlight.dart';

class WidgetMiniScreenPreview extends StatelessWidget {
  final PaletteColorSlot selectedSlot;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const WidgetMiniScreenPreview({
    required this.selectedSlot,
    required this.onSlotSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ColoredBox(
      color: isDark
          ? colors.surfaceContainerHighest.withValues(alpha: 0.55)
          : colors.surfaceContainerHigh.withValues(alpha: 0.75),
      child: CenteredStageScroll(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(
                MiniPreviewStyle.widgetCardRadius,
              ),
              border: Border.all(
                color: colors.outlineVariant.withValues(
                  alpha: MiniPreviewStyle.footerBorderAlpha,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(
                    alpha: isDark ? 0.28 : 0.08,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WidgetHeader(count: schedulePreviewSamples.length),
                const SizedBox(height: 6),
                for (var i = 0; i < schedulePreviewSamples.length; i++) ...[
                  if (i > 0) const SizedBox(height: 4),
                  Builder(
                    builder: (context) {
                      final lesson = schedulePreviewSamples[i];
                      final lessonColor = theme.getColorOfSubjectType(
                        lesson.type,
                      );
                      return SlotHighlight(
                        active: selectedSlot == lesson.slot,
                        borderRadius: BorderRadius.circular(
                          MiniPreviewStyle.smallRadius,
                        ),
                        onTap: () => onSlotSelected(lesson.slot),
                        child: MiniLessonTile(
                          title: lesson.title,
                          subtitle: lesson.widgetSubtitle,
                          startTime: lesson.startTime,
                          endTime: lesson.endTime,
                          barColor: lessonColor,
                          backgroundColor: lesson.isCurrent
                              ? lessonColor.withValues(alpha: 0.08)
                              : null,
                          showBorder: false,
                          borderRadius: MiniPreviewStyle.smallRadius,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          barHeight: null,
                          barSpacing: 7,
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Открыть расписание',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: MiniPreviewStyle.fontSizeSmall,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.north_east_rounded,
                      size: 11,
                      color: colors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WidgetHeader extends StatelessWidget {
  final int count;

  const _WidgetHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 11, color: colors.primary),
            const SizedBox(width: 4),
            Text(
              'Расписание',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
                fontSize: MiniPreviewStyle.fontSizeTitle,
              ),
            ),
            const Spacer(),
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withValues(alpha: 0.12),
              ),
              child: Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: MiniPreviewStyle.fontSizeSmall,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Пн, 23 нояб. · ИИТММ',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: MiniPreviewStyle.fontSizeSmall,
          ),
        ),
      ],
    );
  }
}
