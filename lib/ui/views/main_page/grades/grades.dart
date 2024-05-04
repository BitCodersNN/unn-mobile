import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/mark_by_subject.dart';
import 'package:unn_mobile/core/viewmodels/grades_screen_view_model.dart';
import 'package:unn_mobile/ui/builders/online_status_stream_builder.dart';
import 'package:unn_mobile/ui/views/base_view.dart';

class GradesScreenView extends StatelessWidget {
  const GradesScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<GradesScreenViewModel>(
      builder: (context, value, child) {
        return OnlineStatusStreamBuilder(
          onlineWidget:
              _getGradesBook(context: context, model: value, offline: false),
          offlineWidget:
              _getGradesBook(context: context, model: value, offline: true),
        );
      },
    );
  }

  Widget _getGradesBook({
    required bool offline,
    required GradesScreenViewModel model,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return FutureBuilder(
      future: model.getGradeBook(offline: offline),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Произошла ошибка :('),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          final tabs = snapshot.data!.keys.toList();
          tabs.sort();
          return DefaultTabController(
            initialIndex: tabs.length - 1,
            length: tabs.length,
            child: Column(
              children: [
                Container(
                  color: theme.colorScheme.background,
                  child: TabBar.secondary(
                    tabAlignment: TabAlignment.start,
                    enableFeedback: false,
                    isScrollable: true,
                    tabs: [
                      for (final tab in tabs)
                        Tab(
                          child: Text('Семестр $tab'),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      for (final tab in tabs)
                        SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Table(
                              border: TableBorder.all(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(4.0),
                                ),
                              ),
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: theme.highlightColor,
                                  ),
                                  children: const [
                                    TableCell(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Дисциплина',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Вид контроля',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Оценка',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                for (final row in snapshot.data![tab]!)
                                  TableRow(
                                    children: [
                                      TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            row.subject,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            row.controlType,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            row.markType.convertToString(),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const Center(
          child: SizedBox(
            height: 100.0,
            width: 100.0,
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
