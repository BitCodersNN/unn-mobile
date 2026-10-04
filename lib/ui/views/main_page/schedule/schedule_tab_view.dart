// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_parser.dart';
import 'package:unn_mobile/core/misc/user/user_functions.dart';
import 'package:unn_mobile/core/models/schedule/subject.dart';
import 'package:unn_mobile/core/viewmodels/main_page/schedule/schedule_tab_view_model.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/widgets/day_header.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/widgets/query_chip.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/widgets/schedule_item_normal.dart';
import 'package:unn_mobile/ui/widgets/empty_state_widget.dart';

class ScheduleTabView extends StatefulWidget {
  final ScheduleTabViewModel viewModel;
  final VoidCallback? onSearchRequested;

  const ScheduleTabView({
    required this.viewModel,
    this.onSearchRequested,
    super.key,
  });

  @override
  State<ScheduleTabView> createState() => _ScheduleTabViewState();
}

class _ScheduleTabViewState extends State<ScheduleTabView> {
  final List<GlobalKey> _dayAnchorKeys = List.generate(6, (_) => GlobalKey());

  final GlobalKey _scrollAreaKey = GlobalKey();

  bool _pendingScrollToToday = false;
  String? _scrollContextKey;
  List<List<Subject>>? _displayedSchedule;
  int _displayedWeekOffset = 0;
  double _transitionDirection = 0;

  void _updateScrollTrigger(ScheduleTabViewModel model) {
    if (model.triggerScrollToToday) {
      model.triggerScrollToToday = false;
      _pendingScrollToToday = true;
      return;
    }

    final key = model.scrollContextKey(widget.viewModel.weekOffset);
    if (key == _scrollContextKey) {
      return;
    }
    _scrollContextKey = key;
    _pendingScrollToToday = widget.viewModel.weekOffset == 0;
  }

  void _maybeScrollToToday(ScheduleTabViewModel model) {
    _updateScrollTrigger(model);
    if (!_pendingScrollToToday || model.isBusy) {
      return;
    }
    if (model.schedule == null) {
      return;
    }
    _pendingScrollToToday = false;
    final target = model.todayOrNextDayIndex;
    if (target == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final anchorContext = _dayAnchorKeys[target].currentContext;
      if (anchorContext == null) {
        return;
      }
      final anchor = anchorContext.findRenderObject();
      if (anchor == null) {
        return;
      }
      Scrollable.of(anchorContext).position.ensureVisible(
            anchor,
            alignment: 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
    });
  }

  Widget _dayGroup(
    int i,
    List<Subject> l,
    ScheduleTabViewModel model,
    ThemeData theme,
    DateTime now,
  ) {
    final date =
        (model.scheduleWeek ?? model.selectedWeek).start.add(Duration(days: i));
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 4,
            key: _dayAnchorKeys[i],
          ),
        ),
        SliverAppBar(
          title: DayHeader(
            dayOfWeek:
                l.firstOrNull?.dateTimeRange.start.format(DatePattern.e) ??
                    '(ಠ_ಠ)',
            formattedDate: DateTimeParser.format(date, DatePattern.dMMM)
                .replaceAll('.', ''),
            lessonsCount: l.length,
            isToday: date.isSameDate(now),
          ),
          backgroundColor: theme.colorScheme.surface,
          primary: false,
          pinned: true,
          scrolledUnderElevation: 0,
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              for (final (si, subj) in l.indexed)
                ScheduleItemNormal(
                  subject: subj,
                  even: si.isEven,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _queryResetChip(BuildContext context, ScheduleTabViewModel model) {
    final theme = Theme.of(context);
    return Tooltip(
      message: 'Сбросить запрос',
      child: InkWell(
        onTap: () => model.clearSearch(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.25),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Запрос: ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  shortName(model.foundName!),
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.close,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BaseView<ScheduleTabViewModel>(
        builder: (context, model, _) {
          if (model.isBusy && model.schedule == null) {
            return const Center(
              child: SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }

          if (!model.isBusy && model.schedule != _displayedSchedule) {
            _transitionDirection = _displayedSchedule == null
                ? 0
                : (model.weekOffset - _displayedWeekOffset).sign.toDouble();
            _displayedSchedule = model.schedule;
            _displayedWeekOffset = model.weekOffset;
          }

          return Stack(
            children: [
              TweenAnimationBuilder<double>(
                key: ObjectKey(_displayedSchedule),
                tween: Tween(begin: _transitionDirection == 0 ? 1 : 0, end: 1),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(
                  opacity: 0.85 + value * 0.15,
                  child: FractionalTranslation(
                    translation: Offset(
                      _transitionDirection * 0.06 * (1 - value),
                      0,
                    ),
                    child: child,
                  ),
                ),
                child: OnlineStatusBuilder(
                  builder: (context, isOnline) {
                    if (!model.hasAnyId) {
                      return EmptyStateWidget(
                        icon: Icons.search_outlined,
                        title: 'Расписание не выбрано',
                        caption: isOnline
                            ? 'Введите группу, фамилию или предмет в поиске, '
                                'чтобы посмотреть расписание'
                            : 'Нет сохранённого расписания',
                        onIconTap: isOnline ? widget.onSearchRequested : null,
                      );
                    }

                    if (!isOnline && model.schedule == null) {
                      return const EmptyStateWidget(
                        icon: Icons.cloud_off_outlined,
                        title: 'Нет сохранённого расписания',
                        caption:
                            'Подключитесь к сети, чтобы загрузить расписание',
                      );
                    }

                    final schedule = model.schedule ?? [];
                    final theme = Theme.of(context);
                    final now = DateTime.now();

                    _maybeScrollToToday(model);

                    if (schedule.every((d) => d.isEmpty)) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'На этой неделе занятий нет :)',
                                softWrap: true,
                              ),
                              if (model.foundName != null) ...[
                                const SizedBox(height: 12),
                                _queryResetChip(context, model),
                                const SizedBox(height: 4),
                              ],
                              TextButton(
                                onPressed: () async {
                                  await model.refresh();
                                },
                                child: const Text('Обновить'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Stack(
                      children: [
                        RefreshIndicator(
                          onRefresh: () async {
                            await model.refresh();
                          },
                          child: CustomScrollView(
                            key: _scrollAreaKey,
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              if (schedule.any((d) => d.isNotEmpty))
                                for (final (i, l) in schedule.indexed)
                                  if (l.isNotEmpty)
                                    _dayGroup(i, l, model, theme, now),
                              const SliverToBoxAdapter(
                                child: SizedBox(
                                  height: 20.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (model.foundName != null)
                          Align(
                            alignment: AlignmentGeometry.topRight,
                            child: Container(
                              constraints: const BoxConstraints(
                                maxWidth: 200.0,
                                maxHeight: 60.0,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: QueryChip(
                                  label: model.foundName!,
                                  onClear: model.clearSearch,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: model.isBusy ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: TickerMode(
                      enabled: model.isBusy,
                      child: const LinearProgressIndicator(minHeight: 2),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        model: widget.viewModel,
      );
}
