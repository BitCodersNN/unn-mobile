import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/source_page_view_model.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/source/source_course_view.dart';
import 'package:unn_mobile/ui/views/main_page/source/source_webinar_view.dart';
import 'package:unn_mobile/ui/widgets/dialogs/radio_group_dialog.dart';
import 'package:unn_mobile/ui/widgets/offline_overlay_displayer.dart';

class SourcePageView extends StatelessWidget {
  final int routeIndex;

  static const _selectSemesterKey = 'selectSemester';

  const SourcePageView({super.key, this.routeIndex = 3});

  @override
  Widget build(BuildContext context) {
    final viewModel = Injector.appInstance
        .get<MainPageRoutesViewModelsFactory>()
        .getViewModelByRouteIndex<SourcePageViewModel>(routeIndex);
    final parentScaffold = Scaffold.maybeOf(context);
    return OfflineOverlayDisplayer(
      child: OnlineStatusBuilder(
        builder: (context, online) {
          return BaseView<SourcePageViewModel>(
            model: viewModel,
            builder: (context, model, child) {
              return DefaultTabController(
                length: 2,
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('Материалы'),
                    bottom: const TabBar.secondary(
                      tabs: [
                        Tab(
                          child: Text('Учебные материалы'),
                        ),
                        Tab(
                          child: Text('Онлайн-занятия'),
                        ),
                      ],
                    ),
                    actions: [
                      if (model.semesters.isNotEmpty)
                        PopupMenuButton(
                          itemBuilder: (context) {
                            return [
                              const PopupMenuItem(
                                value: _selectSemesterKey,
                                child: Text('Выбрать семестр'),
                              ),
                            ];
                          },
                          onSelected: (value) async {
                            switch (value) {
                              case _selectSemesterKey:
                                final selectedSem = await showDialog<int?>(
                                  context: context,
                                  builder: (context) {
                                    return RadioGroupDialog(
                                      label: const Text('Выберите семестр:'),
                                      initialIndex:
                                          model.currentSemesterIndex ?? 0,
                                      radioLabels: model.semesters
                                          .map(
                                            (s) => Text(
                                              '${s.semester} семестр, '
                                              '${s.year} год',
                                            ),
                                          )
                                          .toList(),
                                    );
                                  },
                                );
                                if (selectedSem == null) {
                                  return;
                                }
                                model.setSemester(selectedSem);
                                break;
                            }
                          },
                        ),
                    ],
                    leading: parentScaffold?.hasDrawer ?? false
                        ? IconButton(
                            onPressed: () {
                              parentScaffold?.openDrawer();
                            },
                            icon: const Icon(Icons.menu),
                          )
                        : null,
                  ),
                  body: TabBarView(
                    children: [
                      Builder(
                        builder: (context) {
                          if (model.isBusy) {
                            return const Center(
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (model.hasMaterialsError ||
                              model.courses.isEmpty) {
                            return RefreshIndicator(
                              onRefresh: () async => await model.refresh(),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth,
                                        minHeight: constraints.maxHeight,
                                      ),
                                      child: Center(
                                        child: Text(
                                          model.materialsError ??
                                              (model.courses.isEmpty
                                                  ? 'Нет доступных материалов'
                                                  : ''),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                          final list = model.courses.toList();
                          return RefreshIndicator(
                            onRefresh: () async => model.refresh(),
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                return SourceCourseView(model: list[index]);
                              },
                            ),
                          );
                        },
                      ),
                      // --------------------------
                      // ссылки
                      // --------------------------
                      Builder(
                        builder: (context) {
                          if (model.isBusy) {
                            return const Center(
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (model.hasWebinarsError ||
                              model.webinars.isEmpty) {
                            return RefreshIndicator(
                              onRefresh: () async => await model.refresh(),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth,
                                        minHeight: constraints.maxHeight,
                                      ),
                                      child: Center(
                                        child: Text(
                                          model.webinarsError ??
                                              (model.webinars.isEmpty
                                                  ? 'Нет доступных ссылок'
                                                  : ''),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                          final dates =
                              model.webinars.keys.toList().reversed.toList();
                          final theme = Theme.of(context);
                          return RefreshIndicator(
                            onRefresh: () async => await model.refresh(),
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: dates.length,
                              itemBuilder: (context, index) {
                                final date = dates[index];

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                        horizontal: 28.0,
                                      ),
                                      child: Text(
                                        date.format(DatePattern.dMMMM),
                                        style: theme.textTheme.headlineSmall,
                                      ),
                                    ),
                                    for (final webinar
                                        in model.webinars[date] ?? [])
                                      SourceWebinarView(model: webinar),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            onModelReady: (model) => model.init(),
          );
        },
      ),
    );
  }
}
