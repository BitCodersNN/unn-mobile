// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/schedule/subject.dart';
import 'package:unn_mobile/core/viewmodels/main_page/schedule/schedule_tab_view_model.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/widgets/schedule_item_normal.dart';

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

  static const _shortMonths = [
    'янв',
    'фев',
    'мар',
    'апр',
    'мая',
    'июн',
    'июл',
    'авг',
    'сен',
    'окт',
    'ноя',
    'дек',
  ];

  static String _formatDate(DateTime d) =>
      '${d.day} ${_shortMonths[d.month - 1]}';

  static String _shortName(String full) => full
      .split(' ')
      .where((s) => s.isNotEmpty)
      .indexed
      .map((p) => p.$1 == 0 ? p.$2 : '${p.$2[0]}.')
      .join(' ');

  String _contextKey(ScheduleTabViewModel model) =>
      '${widget.weekOffset}|${model.selectedId ?? ''}|${model.foundName ?? ''}';

  void _updateScrollTrigger(ScheduleTabViewModel model) {
    final key = _contextKey(model);
    if (key == _scrollContextKey) {
      return;
    }
    _scrollContextKey = key;
    _pendingScrollToToday = widget.weekOffset == 0;
  }

  int? _targetDayIndex(List<List<Subject>> schedule) {
    final todayIndex = DateTime.now().weekday - 1;
    if (todayIndex > 5) {
      return null;
    }
    for (var i = todayIndex; i < schedule.length && i < 6; i++) {
      if (schedule[i].isNotEmpty) {
        return i;
      }
    }
    return null;
  }

  void _maybeScrollToToday(ScheduleTabViewModel model) {
    _updateScrollTrigger(model);
    if (!_pendingScrollToToday || model.isBusy) {
      return;
    }
    final schedule = model.schedule;
    if (schedule == null) {
      return;
    }
    _pendingScrollToToday = false;
    final target = _targetDayIndex(schedule);
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
    var top = _topDayIndex;
    for (var i = 0; i < 6; i++) {
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

  int? _chipDayIndex(
    ScheduleTabViewModel model,
    List<List<Subject>> schedule,
  ) {
    if (model.foundName == null) {
      return null;
    }
    final todayIndex = DateTime.now().weekday - 1;
    if (_topDayIndex != todayIndex) {
      return _topDayIndex;
    }
    for (var i = todayIndex + 1; i < schedule.length && i < 6; i++) {
      if (schedule[i].isNotEmpty) {
        return i;
      }
    }
    return null;
  }

  bool _isSameDate(DateTime date1, DateTime date2) =>
      date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;

  Widget _emptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String caption,
    VoidCallback? onIconTap,
  }) {
    final theme = Theme.of(context);
    final circle = Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 40,
        color: theme.colorScheme.primary,
      ),
    );
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            onIconTap == null
                ? circle
                : InkWell(
                    onTap: onIconTap,
                    borderRadius: BorderRadius.circular(48),
                    child: circle,
                  ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              caption,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
                return _emptyState(
                  context,
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
                return _emptyState(
                  context,
                  icon: Icons.cloud_off_outlined,
                  title: 'Нет сохранённого расписания',
                  caption: 'Подключитесь к сети, чтобы загрузить расписание',
                );
              }

              final schedule = model.schedule ?? [];
              final theme = Theme.of(context);
              final now = DateTime.now();
              final chipDay = _chipDayIndex(model, schedule);

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
                            SliverMainAxisGroup(
                              slivers: [
                                SliverToBoxAdapter(
                                  child: SizedBox(
                                    height: 0,
                                    key: _dayAnchorKeys[i],
                                  ),
                                ),
                                SliverAppBar(
                                  title: Builder(
                                    builder: (context) {
                                      final date = widget
                                          .selectedTimeRange.start
                                          .add(Duration(days: i));
                                      final isToday = _isSameDate(date, now);

                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            daysOfWeek[i].toUpperCase(),
                                            style: theme.textTheme.titleMedium!
                                                .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            _formatDate(date),
                                            style: theme.textTheme.titleMedium!
                                                .copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: theme.colorScheme.primary
                                                  .withValues(alpha: 0.12),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              '${l.length}',
                                              style: theme
                                                  .textTheme.labelMedium!
                                                  .copyWith(
                                                color:
                                                    theme.colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Container(
                                              height: 1.0,
                                              color: theme.dividerColor
                                                  .withValues(alpha: 0.25),
                                            ),
                                          ),
                                          if (isToday) ...[
                                            const SizedBox(width: 12),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    theme.colorScheme.primary,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                'Сегодня',
                                                style: TextStyle(
                                                  color: theme
                                                      .colorScheme.onPrimary,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ] else if (i == chipDay) ...[
                                            const SizedBox(width: 12),
                                            _QueryChip(
                                              label: _shortName(
                                                model.foundName!,
                                              ),
                                              onClear: () =>
                                                  model.clearSearch(),
                                            ),
                                          ],
                                        ],
                                      );
                                    },
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
                            ),
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

/// Чип запроса с плавной анимацией появления
class _QueryChip extends StatefulWidget {
  final String label;
  final VoidCallback onClear;

  const _QueryChip({
    required this.label,
    required this.onClear,
  });

  @override
  State<_QueryChip> createState() => _QueryChipState();
}

class _QueryChipState extends State<_QueryChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 220),
    vsync: this,
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  late final Animation<double> _scale =
      Tween<double>(begin: 0.8, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        // растёт от правого края — там расположен слот чипа
        alignment: Alignment.centerRight,
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: widget.onClear,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.close,
                    size: 12,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
