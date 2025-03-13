import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:injector/injector.dart';
import 'package:mime/mime.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/file_helpers/file_functions.dart';
import 'package:unn_mobile/core/misc/html_widget_callbacks.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/source_course_view_model.dart';
import 'package:unn_mobile/core/viewmodels/source_item_view_model.dart';
import 'package:unn_mobile/core/viewmodels/source_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/source_webinar_view_model.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
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
                          return ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              return SourceCourseView(model: list[index]);
                            },
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
                          final dates = model.webinars.keys.toList();
                          final theme = Theme.of(context);
                          return ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: dates.length,
                            itemBuilder: (context, index) {
                              final date = dates[index];
                              return ExpansionTile(
                                expandedCrossAxisAlignment:
                                    CrossAxisAlignment.start,
                                shape: const Border(),
                                title: Text(
                                  date.format(DatePattern.dMMMM),
                                  style: theme.textTheme.headlineSmall,
                                ),
                                children: List.generate(
                                  model.webinars[date]?.length ?? 0,
                                  (i) => SourceWebinarView(
                                    model: model.webinars[date]![i],
                                  ),
                                ),
                              );
                            },
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

class SourceCourseView extends StatelessWidget {
  final SourceCourseViewModel model;
  const SourceCourseView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return BaseView<SourceCourseViewModel>(
      model: model,
      builder: (context, model, _) {
        final theme = Theme.of(context);
        return ExpansionTile(
          title: Text(
            model.discipline,
            style: theme.textTheme.headlineSmall,
          ),
          shape: const Border(),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: model.items.map((i) => SourceItemView(model: i)).toList(),
        );
      },
    );
  }
}

class SourceItemView extends StatelessWidget {
  final SourceItemViewModel model;
  const SourceItemView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return BaseView<SourceItemViewModel>(
      model: model,
      builder: (context, model, _) {
        return Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (model.comment.isNotEmpty) Text(model.comment),
                        if (model.isLink)
                          HtmlWidget(
                            '<a href="${model.link}">${model.link}</a>',
                            onTapUrl: htmlWidgetOnTapUrl,
                          )
                        else if (model.isFile)
                          Text('Файл: ${model.fileName}'),
                      ],
                    ),
                  ),
                  if (model.isFile)
                    ElevatedButton(
                      onPressed: () async {
                        await model.downloadFile();
                      },
                      child: const Text('Скачать'),
                    ),
                ],
              ),
            ),
            const Divider(),
          ],
        );
      },
      onModelReady: (p0) {
        if (model.isFile) {
          model.onFileDownloaded = (file) {
            final mimeType = lookupMimeType(file.path);
            if (mimeType != null) {
              viewFile(file.path, mimeType);
            }
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(
              const SnackBar(
                content: Text('Файл сохранён'),
              ),
            );
          };
        }
      },
    );
  }
}

class SourceWebinarView extends StatelessWidget {
  final SourceWebinarViewModel model;

  const SourceWebinarView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return BaseView<SourceWebinarViewModel>(
      builder: (context, model, _) {
        final theme = Theme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.title,
                    style: theme.textTheme.titleLarge,
                  ),
                  SelectableText('Комментарий: ${model.comment}'),
                  if (model.urlStream?.isNotEmpty ?? false)
                    HtmlWidget(
                      'Ссылка на трансляцию: <a href="${model.urlStream}">${model.urlStream}</a>',
                      onTapUrl: htmlWidgetOnTapUrl,
                    ),
                  if (model.urlRecord?.isNotEmpty ?? false)
                    HtmlWidget(
                      'Ссылка на запись: <a href="${model.urlRecord}">${model.urlRecord}</a>',
                      onTapUrl: htmlWidgetOnTapUrl,
                    ),
                ],
              ),
            ),
            const Divider(),
          ],
        );
      },
      model: model,
    );
  }
}
