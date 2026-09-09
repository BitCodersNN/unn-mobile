// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page/schedule/schedule_tab_view_model.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/widgets/schedule_item_normal.dart';

class ScheduleTabView extends StatelessWidget {
  final ScheduleTabViewModel viewModel;

  static const daysOfWeek = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];

  const ScheduleTabView({required this.viewModel, super.key});

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
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: isOnline
                        ? const Text('Введите запрос для поиска')
                        : const Text('Нет сохранённого расписания'),
                  ),
                );
              }

              if (!isOnline && model.schedule == null) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Нет сохранённого расписания',
                      softWrap: true,
                    ),
                  ),
                );
              }

              final schedule = model.schedule ?? [];

              final theme = Theme.of(context);
              return Stack(
                children: [
                  if (schedule.every((d) => d.isEmpty))
                    Center(
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
                    )
                  else
                    RefreshIndicator(
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
                                      title: Text(daysOfWeek[i]),
                                      backgroundColor:
                                          theme.colorScheme.surface,
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
                  if (model.foundName != null)
                    Positioned(
                      top: 4.0,
                      right: 12.0,
                      child: Chip(
                        label: Text(
                          model.foundName!
                              .split(' ')
                              .indexed
                              .map(
                                (p) => p.$1 == 0 ? p.$2 : '${p.$2[0]}.',
                              )
                              .join(' '),
                        ),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () async {
                          await model.clearSearch();
                        },
                      ),
                    ),
                ],
              );
            },
          );
        },
        model: viewModel,
      );
}
