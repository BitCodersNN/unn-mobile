// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/core/models/grade_book/mark_type.dart';
import 'package:unn_mobile/core/models/schedule/subject_type.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/slot_highlight.dart';

class BaseCategoryPreview extends StatelessWidget {
  final PageController pageController;
  final PaletteColorSlot selectedSlot;
  final ValueChanged<PaletteColorSlot> onSlotSelected;
  final ValueChanged<int> onPageChanged;

  const BaseCategoryPreview({
    required this.pageController,
    required this.selectedSlot,
    required this.onSlotSelected,
    required this.onPageChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    void onBackgroundTap() => onSlotSelected(PaletteColorSlot.surface);
    return PageView(
      controller: pageController,
      onPageChanged: onPageChanged,
      children: [
        _MiniScreenFrame(
          appBar: const _MiniAppBar(title: 'Лента'),
          onBackgroundTap: onBackgroundTap,
          body: _FeedMiniScreenBody(
            selectedSlot: selectedSlot,
            onSlotSelected: onSlotSelected,
          ),
          bottomBar: _MiniBottomNavBar(
            activeIndex: 0,
            selectedSlot: selectedSlot,
            onSlotSelected: onSlotSelected,
          ),
        ),
        _MiniScreenFrame(
          appBar: const _MiniAppBar(title: 'Зачётная книжка'),
          onBackgroundTap: onBackgroundTap,
          body: _GradesMiniScreenBody(
            selectedSlot: selectedSlot,
            onSlotSelected: onSlotSelected,
          ),
          bottomBar: _MiniBottomNavBar(
            activeIndex: 2,
            selectedSlot: selectedSlot,
            onSlotSelected: onSlotSelected,
          ),
        ),
        _MiniScreenFrame(
          appBar: const _MiniAppBar(title: 'Расписание'),
          onBackgroundTap: onBackgroundTap,
          body: _ScheduleMiniScreenBody(
            selectedSlot: selectedSlot,
            onSlotSelected: onSlotSelected,
          ),
          bottomBar: _MiniBottomNavBar(
            activeIndex: 1,
            selectedSlot: selectedSlot,
            onSlotSelected: onSlotSelected,
          ),
        ),
        _MiniScreenFrame(
          appBar: const _MiniAppBar(title: 'Настройки'),
          onBackgroundTap: onBackgroundTap,
          body: _SettingsMiniScreenBody(
            selectedSlot: selectedSlot,
            onSlotSelected: onSlotSelected,
          ),
        ),
      ],
    );
  }
}

class _MiniScreenFrame extends StatelessWidget {
  final Widget appBar;
  final Widget body;
  final Widget? bottomBar;
  final VoidCallback? onBackgroundTap;

  const _MiniScreenFrame({
    required this.appBar,
    required this.body,
    this.bottomBar,
    this.onBackgroundTap,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              appBar,
              Expanded(
                child: onBackgroundTap == null
                    ? body
                    : GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: onBackgroundTap,
                        child: body,
                      ),
              ),
              ?bottomBar,
            ],
          ),
        ),
      ),
    ),
  );
}

class _MiniAppBar extends StatelessWidget {
  final String title;

  const _MiniAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appBarBg = theme.appBarTheme.backgroundColor ?? colors.surface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: appBarBg,
        border: Border(
          bottom: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBottomNavBar extends StatelessWidget {
  static const _items = [
    Icons.newspaper_rounded,
    Icons.calendar_today_rounded,
    Icons.school_outlined,
    Icons.settings_outlined,
  ];

  final int activeIndex;
  final PaletteColorSlot selectedSlot;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const _MiniBottomNavBar({
    required this.activeIndex,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      color: colors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < _items.length; i++)
            Builder(
              builder: (context) {
                final isActive = i == activeIndex;
                final iconWidget = Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  child: Icon(
                    _items[i],
                    size: 15,
                    color: isActive ? colors.primary : colors.onSurfaceVariant,
                  ),
                );
                if (!isActive) {
                  return iconWidget;
                }
                return SlotHighlight(
                  active: selectedSlot == PaletteColorSlot.primary,
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onSlotSelected(PaletteColorSlot.primary),
                  child: iconWidget,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _FeedMiniScreenBody extends StatelessWidget {
  final PaletteColorSlot selectedSlot;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const _FeedMiniScreenBody({
    required this.selectedSlot,
    required this.onSlotSelected,
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
              borderRadius: BorderRadius.circular(14),
              onTap: () =>
                  onSlotSelected(PaletteColorSlot.importantPostHighlight),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(14),
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
                              fontSize: 11,
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Важное',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: importantColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 8.5,
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
                        fontSize: 10,
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
              borderRadius: BorderRadius.circular(14),
              onTap: () => onSlotSelected(PaletteColorSlot.cardSurface),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
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
                              SlotHighlight(
                                active:
                                    selectedSlot == PaletteColorSlot.onSurface,
                                borderRadius: BorderRadius.circular(4),
                                onTap: () =>
                                    onSlotSelected(PaletteColorSlot.onSurface),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: Text(
                                    'Иван Петров',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: colors.onSurface,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                  ),
                                ),
                              ),
                              SlotHighlight(
                                active:
                                    selectedSlot ==
                                    PaletteColorSlot.onSurfaceVariant,
                                borderRadius: BorderRadius.circular(4),
                                onTap: () => onSlotSelected(
                                  PaletteColorSlot.onSurfaceVariant,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: Text(
                                    '10 мин назад',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 9,
                                    ),
                                  ),
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
                        fontSize: 10,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SlotHighlight(
                      active: selectedSlot == PaletteColorSlot.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                      onTap: () =>
                          onSlotSelected(PaletteColorSlot.outlineVariant),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: colors.outlineVariant,
                        ),
                      ),
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
                            borderRadius: BorderRadius.circular(12),
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
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        SlotHighlight(
                          active: selectedSlot == PaletteColorSlot.secondary,
                          borderRadius: BorderRadius.circular(12),
                          onTap: () =>
                              onSlotSelected(PaletteColorSlot.secondary),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: colors.secondary.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(12),
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
                                    fontSize: 9.5,
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

class _GradesMiniScreenBody extends StatelessWidget {
  static const _rows = [
    ('Математический анализ', 'Экзамен', MarkType.excellent, 'Отлично'),
    ('Алгоритмы и структуры', 'Экзамен', MarkType.good, 'Хорошо'),
  ];

  final PaletteColorSlot selectedSlot;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const _GradesMiniScreenBody({
    required this.selectedSlot,
    required this.onSlotSelected,
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
              borderRadius: BorderRadius.circular(14),
              onTap: () => onSlotSelected(
                selectedSlot == PaletteColorSlot.primary
                    ? PaletteColorSlot.secondary
                    : PaletteColorSlot.primary,
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
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
                              fontSize: 11,
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
              borderRadius: BorderRadius.circular(14),
              onTap: () => onSlotSelected(PaletteColorSlot.cardSurface),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
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
                    for (var i = 0; i < _rows.length; i++) ...[
                      if (i > 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: SlotHighlight(
                            active:
                                selectedSlot == PaletteColorSlot.outlineVariant,
                            borderRadius: BorderRadius.circular(4),
                            onTap: () =>
                                onSlotSelected(PaletteColorSlot.outlineVariant),
                            child: Divider(
                              height: 1,
                              color: colors.outlineVariant,
                            ),
                          ),
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
                                    SlotHighlight(
                                      active:
                                          selectedSlot ==
                                          PaletteColorSlot.onSurface,
                                      borderRadius: BorderRadius.circular(4),
                                      onTap: () => onSlotSelected(
                                        PaletteColorSlot.onSurface,
                                      ),
                                      child: Text(
                                        row.$1,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: colors.onSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    SlotHighlight(
                                      active:
                                          selectedSlot ==
                                          PaletteColorSlot.onSurfaceVariant,
                                      borderRadius: BorderRadius.circular(4),
                                      onTap: () => onSlotSelected(
                                        PaletteColorSlot.onSurfaceVariant,
                                      ),
                                      child: Text(
                                        row.$2,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: colors.onSurfaceVariant,
                                              fontSize: 9.5,
                                            ),
                                      ),
                                    ),
                                  ],
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
                                  row.$4,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: markColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
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
                fontSize: 8.5,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.labelLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleMiniScreenBody extends StatelessWidget {
  final PaletteColorSlot selectedSlot;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const _ScheduleMiniScreenBody({
    required this.selectedSlot,
    required this.onSlotSelected,
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
                borderRadius: BorderRadius.circular(8),
              ),
              child: SlotHighlight(
                active: selectedSlot == PaletteColorSlot.onSurface,
                borderRadius: BorderRadius.circular(4),
                onTap: () => onSlotSelected(PaletteColorSlot.onSurface),
                child: Text(
                  'Понедельник · 23 ноября',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            _MiniLessonCard(
              title: 'Математический анализ',
              subtitle: '09:00–10:30 · Ауд. 214',
              backgroundColor:
                  extra?.scheduleSubjectHighlight ?? theme.cardColor,
              barColor: theme.getColorOfSubjectType(SubjectType.lecture),
            ),
            const SizedBox(height: 5),
            SlotHighlight(
              active: selectedSlot == PaletteColorSlot.cardSurface,
              borderRadius: BorderRadius.circular(10),
              onTap: () => onSlotSelected(PaletteColorSlot.cardSurface),
              child: _MiniLessonCard(
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

class _MiniLessonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color barColor;

  const _MiniLessonCard({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 22,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.5,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsMiniScreenBody extends StatelessWidget {
  final PaletteColorSlot selectedSlot;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const _SettingsMiniScreenBody({
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SlotHighlight(
              active: selectedSlot == PaletteColorSlot.cardSurface,
              borderRadius: BorderRadius.circular(12),
              onTap: () => onSlotSelected(PaletteColorSlot.cardSurface),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MiniSettingsRow(
                      icon: Icons.notifications_outlined,
                      title: 'Уведомления',
                      subtitle: 'Новые записи в ленте',
                      selectedSlot: selectedSlot,
                      highlightDetails: true,
                      onSlotSelected: onSlotSelected,
                    ),
                    SlotHighlight(
                      active: selectedSlot == PaletteColorSlot.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                      onTap: () =>
                          onSlotSelected(PaletteColorSlot.outlineVariant),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: colors.outlineVariant,
                      ),
                    ),
                    _MiniSettingsRow(
                      icon: Icons.vibration_rounded,
                      title: 'Вибрация',
                      subtitle: 'Тактильный отклик',
                      selectedSlot: selectedSlot,
                      highlightDetails: false,
                      onSlotSelected: onSlotSelected,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SlotHighlight(
              active:
                  selectedSlot == PaletteColorSlot.primary ||
                  selectedSlot == PaletteColorSlot.secondary,
              borderRadius: BorderRadius.circular(20),
              onTap: () => onSlotSelected(PaletteColorSlot.primary),
              child: SizedBox(
                height: 30,
                child: FilledButton(
                  onPressed: () => onSlotSelected(PaletteColorSlot.primary),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    textStyle: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Сохранить'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniSettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final PaletteColorSlot selectedSlot;
  final bool highlightDetails;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const _MiniSettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selectedSlot,
    required this.highlightDetails,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          SlotHighlight(
            active:
                highlightDetails && selectedSlot == PaletteColorSlot.primary,
            borderRadius: BorderRadius.circular(6),
            onTap: () => onSlotSelected(PaletteColorSlot.primary),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(icon, size: 16, color: colors.primary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SlotHighlight(
                  active:
                      highlightDetails &&
                      selectedSlot == PaletteColorSlot.onSurface,
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => onSlotSelected(PaletteColorSlot.onSurface),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ),
                SlotHighlight(
                  active:
                      highlightDetails &&
                      selectedSlot == PaletteColorSlot.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                  onTap: () =>
                      onSlotSelected(PaletteColorSlot.onSurfaceVariant),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SlotHighlight(
            active:
                highlightDetails && selectedSlot == PaletteColorSlot.primary,
            borderRadius: BorderRadius.circular(14),
            onTap: () => onSlotSelected(PaletteColorSlot.primary),
            child: SizedBox(
              height: 22,
              child: FittedBox(
                child: Switch(
                  value: true,
                  onChanged: (_) => onSlotSelected(PaletteColorSlot.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
