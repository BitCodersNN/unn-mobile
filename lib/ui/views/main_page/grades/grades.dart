import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/models/mark_by_subject.dart';
import 'package:unn_mobile/core/viewmodels/grades_screen_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';

class GradesScreenView extends StatefulWidget {
  const GradesScreenView({super.key});

  @override
  State<GradesScreenView> createState() => _GradesScreenViewState();
}

class _GradesScreenViewState extends State<GradesScreenView> {
  @override
  Widget build(BuildContext context) {
    return BaseView<GradesScreenViewModel>(
      builder: (context, value, child) {
        return _getGradesBook(context: context, model: value);
      },
    );
  }

  Widget _getGradesBook({
    required GradesScreenViewModel model,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return FutureBuilder(
      future: model.getGradeBook(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Произошла ошибка :('),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
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
                                            'Дата',
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
                                              DateFormat.yMd('ru_RU')
                                                  .format(row.date),
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
          } else {
            return Center(
              child: Column(
                children: [
                  const Text('Ещё нет загруженной версии зачётной книжки'),
                  TextButton(
                    onPressed: () {
                      // Force redraw
                      setState(() {});
                    },
                    child: const Text('Обновить'),
                  ),
                ],
              ),
            );
          }
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
