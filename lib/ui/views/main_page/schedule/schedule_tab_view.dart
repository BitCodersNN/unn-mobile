// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/models/schedule/subject.dart';
import 'package:unn_mobile/core/viewmodels/main_page/schedule/schedule_tab_view_model.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/widgets/day_header.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/widgets/schedule_item_normal.dart';
import 'package:unn_mobile/ui/widgets/empty_state_widget.dart';

class ScheduleTabView extends StatefulWidget {
  final ScheduleTabViewModel viewModel;
  final DateTimeRange selectedTimeRange;
  final int weekOffset;

  final VoidCallback? onSearchRequested;

  const ScheduleTabView({
    required this.viewModel,
    required this.selectedTimeRange,
    required this.weekOffset,
    this.onSearchRequested,
    super.key,
  });

  @override
  State<ScheduleTabView> createState() => _ScheduleTabViewState();
}

class _ScheduleTabViewState extends State<ScheduleTabView> {
  final List<GlobalKey> _dayAnchorKeys = List.generate(6, (_) => GlobalKey());

  final GlobalKey _scrollAreaKey = GlobalKey();

  int _topDayIndex = 0;

  bool _pendingScrollToToday = false;
  String? _scrollContextKey;

  static const daysOfWeek = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
  ];

  void _updateScrollTrigger(ScheduleTabViewModel model) {
    if (model.triggerScrollToToday) {
      model.triggerScrollToToday = false;
      _pendingScrollToToday = true;
      return;
    }

    final key = model.scrollContextKey(widget.weekOffset);
    if (key == _scrollContextKey) {
      return;
    }
    _scrollContextKey = key;
    _pendingScrollToToday = widget.weekOffset == 0;
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
      Scrollable.ensureVisible(
        anchorContext,
        alignment: 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _updateTopDay() {
    final scrollContext = _scrollAreaKey.currentContext;
    if (scrollContext == null) {
      return;
    }
    final scrollBox = scrollContext.findRenderObject() as RenderBox?;
    if (scrollBox == null) {
      return;
    }
    final viewportTop = scrollBox.localToGlobal(Offset.zero).dy;
    int top = _topDayIndex;
    for (int i = 0; i < 6; i++) {
      final anchorContext = _dayAnchorKeys[i].currentContext;
      if (anchorContext == null) {
        continue;
      }
      final anchorBox = anchorContext.findRenderObject() as RenderBox?;
      if (anchorBox == null) {
        continue;
      }
      if (anchorBox.localToGlobal(Offset.zero).dy <= viewportTop + 1) {
        top = i;
      }
    }
    if (top != _topDayIndex && mounted) {
      setState(() => _topDayIndex = top);
    }
  }

  Widget _dayGroup(
    int i,
    List<Subject> l,
    ScheduleTabViewModel model,
    ThemeData theme,
    DateTime now,
    int? chipDay,
  ) {
    final date = widget.selectedTimeRange.start.add(Duration(days: i));
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 0,
            key: _dayAnchorKeys[i],
          ),
        ),
        SliverAppBar(
          title: DayHeader(
            dayOfWeek: daysOfWeek[i],
            formattedDate: DayHeader.formatDate(date),
            pairsCount: l.length,
            isToday: date.isSameDate(now),
            showQueryChip: i == chipDay,
            queryLabel: model.foundName,
            onClearQuery: () => model.clearSearch(),
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

  @override
  Widget build(BuildContext context) => BaseView<ScheduleTabViewModel>(
        builder: (context, model, _) {
          if (model.isBusy) {
            return const Center(
              child: SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }

          return OnlineStatusBuilder(
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
                  caption: 'Подключитесь к сети, чтобы загрузить расписание',
                );
              }

              final schedule = model.schedule ?? [];
              final theme = Theme.of(context);
              final now = DateTime.now();
              final chipDay = model.chipDayFor(_topDayIndex);

              _maybeScrollToToday(model);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _updateTopDay();
                }
              });

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

              return NotificationListener<ScrollNotification>(
                onNotification: (_) {
                  _updateTopDay();
                  return false;
                },
                child: RefreshIndicator(
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
                            _dayGroup(i, l, model, theme, now, chipDay),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        model: widget.viewModel,
      );
}
