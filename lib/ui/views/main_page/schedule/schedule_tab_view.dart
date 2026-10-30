// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_parser.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/week_range.dart';
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
  final int weekOffset;
  final VoidCallback? onSearchRequested;

  const ScheduleTabView({
    required this.viewModel,
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

  bool _pendingScrollToToday = false;
  String? _scrollContextKey;
  List<List<Subject>>? _displayedSchedule;
  WeekRange? _displayedWeek;

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

  Widget _dayGroup(int i, List<Subject> l, ThemeData theme, DateTime now) {
    final date = _displayedWeek!.start.add(Duration(days: i));
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: 4, key: _dayAnchorKeys[i])),
        SliverAppBar(
          title: DayHeader(
            dayOfWeek:
                l.firstOrNull?.dateTimeRange.start.format(DatePattern.e) ??
                '(ಠ_ಠ)',
            formattedDate: DateTimeParser.format(
              date,
              DatePattern.dMMM,
            ).replaceAll('.', ''),
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
                ScheduleItemNormal(subject: subj, even: si.isEven),
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
              Icon(Icons.close, size: 16, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BaseView<ScheduleTabViewModel>(
    builder: (context, model, _) {
      final pageWeek = WeekRange(
        weekOffset: widget.weekOffset,
        reference: model.selectedWeek.reference,
      );
      final isSelectedWeek = widget.weekOffset == model.weekOffset;
      if (model.scheduleWeek?.start == pageWeek.start) {
        _displayedSchedule = model.schedule;
        _displayedWeek = model.scheduleWeek;
      }

      return OnlineStatusBuilder(
        builder: (context, isOnline) {
          final offline = model.offlineSchedule;
          if (!isOnline &&
              offline != null &&
              (!model.hasAnyId || _displayedSchedule == null)) {
            _displayedSchedule = model.partitionSchedule(offline.subjects);
            _displayedWeek = offline.week;
          }
          if (isOnline &&
              _displayedSchedule == null &&
              (!isSelectedWeek || model.isBusy)) {
            return const Center(
              child: SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }

          if (!model.hasAnyId && (isOnline || offline == null)) {
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

          if (!isOnline && _displayedSchedule == null) {
            return const EmptyStateWidget(
              icon: Icons.cloud_off_outlined,
              title: 'Нет сохранённого расписания',
              caption: 'Подключитесь к сети, чтобы загрузить расписание',
            );
          }

          final schedule = _displayedSchedule ?? <List<Subject>>[];
          final theme = Theme.of(context);
          final now = DateTime.now();

          if (isSelectedWeek) {
            _maybeScrollToToday(model);
          }

          if (schedule.every((d) => d.isEmpty)) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('На этой неделе занятий нет :)', softWrap: true),
                    if (model.foundName != null) ...[
                      const SizedBox(height: 12),
                      _queryResetChip(context, model),
                      const SizedBox(height: 4),
                    ],
                    TextButton(
                      onPressed: () async {
                        await model.refresh(triggerOfflineUpdate: true);
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
                  await model.refresh(triggerOfflineUpdate: true);
                },
                child: CustomScrollView(
                  key: _scrollAreaKey,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    if (schedule.any((d) => d.isNotEmpty))
                      for (final (i, l) in schedule.indexed)
                        if (l.isNotEmpty) _dayGroup(i, l, theme, now),
                    const SliverToBoxAdapter(child: SizedBox(height: 20.0)),
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
      );
    },
    model: widget.viewModel,
  );
}
