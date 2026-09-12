// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page/schedule/schedule_tab_view_model.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/widgets/schedule_item_normal.dart';

class ScheduleTabView extends StatelessWidget {
  final ScheduleTabViewModel viewModel;
  final DateTimeRange selectedTimeRange;

  static const daysOfWeek = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
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

  const ScheduleTabView({
    required this.viewModel,
    required this.selectedTimeRange,
    super.key,
  });

  bool _isSameDate(DateTime date1, DateTime date2) =>
      date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;

  static String _formatDate(DateTime d) =>
      '${d.day} ${_shortMonths[d.month - 1]}';

  Widget _emptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String caption,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
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
                      ? 'Введите запрос для поиска, '
                          'чтобы посмотреть расписание'
                      : 'Нет сохранённого расписания',
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

              return RefreshIndicator(
                onRefresh: () async {
                  await model.refresh();
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    if (schedule.any((d) => d.isNotEmpty))
                      for (final (i, l) in schedule.indexed)
                        if (l.isNotEmpty)
                          SliverMainAxisGroup(
                            slivers: [
                              SliverAppBar(
                                title: Builder(
                                  builder: (context) {
                                    final date = selectedTimeRange.start
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
                                        const SizedBox(width: 6),
                                        const Text('·'),
                                        const SizedBox(width: 6),
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
                                                .withAlpha(12),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${l.length}',
                                            style: theme.textTheme.labelMedium!
                                                .copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Container(
                                            height: 1.0,
                                            color: theme.dividerColor
                                                .withAlpha(25),
                                          ),
                                        ),
                                        if (isToday) ...[
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Сегодня',
                                              style: TextStyle(
                                                color:
                                                    theme.colorScheme.onPrimary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
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
              );
            },
          );
        },
        model: viewModel,
      );
}
