// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/source/source_page_view_model.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/source/source_course_view.dart';
import 'package:unn_mobile/ui/views/main_page/source/source_semester_selector.dart';
import 'package:unn_mobile/ui/views/main_page/source/source_webinar_view.dart';
import 'package:unn_mobile/ui/widgets/empty_state_widget.dart';
import 'package:unn_mobile/ui/widgets/offline_overlay_displayer.dart';
import 'package:unn_mobile/ui/widgets/section_header.dart';
import 'package:unn_mobile/ui/widgets/segmented_tab_bar.dart';

class SourcePageView extends StatelessWidget {
  const SourcePageView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context
        .read<MainPageRoutesViewModelsFactory>()
        .getOrCreate<SourcePageViewModel>();
    return OfflineOverlayDisplayer(
      child: OnlineStatusBuilder(
        builder: (context, online) => BaseView<SourcePageViewModel>(
          model: viewModel,
          onModelReady: (model) => model.init(),
          builder: (context, model, _) => DefaultTabController(
            length: 2,
            child: Builder(
              builder: (context) {
                final tabs = DefaultTabController.of(context);
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Материалы'),
                    centerTitle: false,
                    forceMaterialTransparency: true,
                  ),
                  body: SafeArea(
                    top: false,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: SourceSemesterSelector(
                                model: model,
                                enabled: online,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              child: AnimatedBuilder(
                                animation: tabs,
                                builder: (context, _) => SegmentedTabBar(
                                  items: const [
                                    SegmentedTabItem(
                                      label: 'Учебные материалы',
                                    ),
                                    SegmentedTabItem(label: 'Онлайн-занятия'),
                                  ],
                                  selectedIndex: tabs.index,
                                  position: tabs.animation,
                                  onSelected: tabs.animateTo,
                                ),
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  _SourceList(model: model),
                                  _SourceList(model: model, webinars: true),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SourceList extends StatelessWidget {
  final SourcePageViewModel model;
  final bool webinars;

  const _SourceList({required this.model, this.webinars = false});

  @override
  Widget build(BuildContext context) {
    final hasError = webinars
        ? model.hasWebinarsError
        : model.hasMaterialsError;
    final isEmpty = webinars ? model.webinars.isEmpty : model.courses.isEmpty;
    final error = webinars ? model.webinarsError : model.materialsError;
    final semesterKey = model.currentSemester?.toString();
    return RefreshIndicator(
      onRefresh: () async => await model.refresh(),
      child: CustomScrollView(
        key: PageStorageKey('$semesterKey-$webinars'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (model.isBusy)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else if (hasError || isEmpty)
            SliverLayoutBuilder(
              builder: (context, constraints) => SliverToBoxAdapter(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.remainingPaintExtent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      EmptyStateWidget(
                        icon: hasError
                            ? Icons.cloud_off_outlined
                            : webinars
                            ? Icons.videocam_outlined
                            : Icons.folder_open_outlined,
                        title: hasError
                            ? 'Не удалось загрузить'
                            : webinars
                            ? 'Нет онлайн-занятий'
                            : 'Пока нет материалов',
                        caption: hasError
                            ? (error ??
                                  'Проверьте подключение и попробуйте ещё раз')
                            : 'Попробуйте выбрать другой семестр или обновить страницу',
                      ),
                      if (hasError)
                        TextButton.icon(
                          onPressed: model.refresh,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Повторить'),
                        ),
                    ],
                  ),
                ),
              ),
            )
          else if (webinars)
            ..._webinars(context)
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.builder(
                itemCount: model.courses.length,
                itemBuilder: (context, index) {
                  final course = model.courses.elementAt(index);
                  return Padding(
                    key: ObjectKey(course),
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SourceCourseView(model: course, even: index.isEven),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _webinars(BuildContext context) {
    final dates = model.webinars.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final date in dates) ...[
        SliverToBoxAdapter(
          child: SectionHeader(
            title: date.format(DatePattern.dMMMM),
            count: model.webinars[date]!.length,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverList.builder(
            itemCount: model.webinars[date]!.length,
            itemBuilder: (context, index) {
              final webinar = model.webinars[date]![index];
              return Padding(
                key: ObjectKey(webinar),
                padding: const EdgeInsets.only(bottom: 12),
                child: SourceWebinarView(model: webinar, even: index.isEven),
              );
            },
          ),
        ),
      ],
    ];
  }
}
