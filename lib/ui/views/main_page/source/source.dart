import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/source_course_view_model.dart';
import 'package:unn_mobile/core/viewmodels/source_item_view_model.dart';
import 'package:unn_mobile/core/viewmodels/source_page_view_model.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/widgets/offline_overlay_displayer.dart';

class SourcePageView extends StatelessWidget {
  final int routeIndex;
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
                    actions: const [
                      // PopupMenuButton(
                      //   itemBuilder: (context) {
                      //     return [
                      //     ];
                      //   },
                      //   onSelected: (value) {
                      //   },
                      // ),
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
                          if (model.hasError) {
                            return RefreshIndicator(
                              onRefresh: () async =>
                                  await model.initCurrentSemester(),
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
                                      child: Center(child: Text(model.error!)),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                          final list = model.courses.toList();
                          return ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: model.courses.length,
                            itemBuilder: (context, index) {
                              return SourceCourseView(model: list[index]);
                            },
                          );
                        },
                      ),
                      const Placeholder(),
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
        return ExpansionTile(
          title: Text(model.discipline),
          shape: const Border(),
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
        if (model.isLink) {
          return HtmlWidget('<a href="${model.link}">${model.comment}</a>');
        }
        if (model.isFile) {
          return Column(
            children: [
              HtmlWidget(
                '${model.comment}: Файл: ${model.fileName}',
                textStyle: const TextStyle(color: Colors.black),
              ),
              ElevatedButton(
                onPressed: () async {
                  await model.downloadFile();
                },
                child: const Text('Скачать'),
              ),
            ],
          );
        }
        return const Text('Неизвестный тип материала');
      },
    );
  }
}
