import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/models/subject.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/schedule_screen_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/widgets/schedule_item_normal.dart';

class ScheduleScreenView extends StatefulWidget {
  const ScheduleScreenView({super.key});

  @override
  State<ScheduleScreenView> createState() => _ScheduleScreenViewState();
}

class _ScheduleScreenViewState extends State<ScheduleScreenView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseView<ScheduleScreenViewModel>(
      builder: (context, model, child) {
        return Column(
          children: [
            TabBar(
              tabs: const [
                Tab(
                  text: 'Студент',
                ),
                Tab(
                  text: 'Группа',
                ),
                Tab(
                  text: 'Преподаватель',
                ),
              ],
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _scheduleTab(theme, model),
                  _scheduleTab(theme, model),
                  _scheduleTab(theme, model),
                ],
              ),
            ),
          ],
        );
      },
      onModelReady: (model) => model.init(),
    );
  }

  Column _scheduleTab(ThemeData theme, ScheduleScreenViewModel model) {
    return Column(
                  children: [
                    SearchAnchor(
                      builder: (context, controller) {
                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: SearchBar(
                            hintText: 'Поиск по группе',
                            leading: const Icon(Icons.search),
                            trailing: [
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.more_horiz))
                            ],
                            shape: MaterialStateProperty.resolveWith(
                              (states) => const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      suggestionsBuilder: (context, controller) {
                        return [const Placeholder()];
                      },
                    ),
                    FutureBuilder(
                      builder: (context, snapshot) {
                        return _customScrollView(theme, snapshot, model);
                      },
                      future: model.scheduleLoader,
                    ),
                  ],
                );
  }

  Widget _customScrollView(
      ThemeData theme,
      AsyncSnapshot<Map<int, List<Subject>>> snapshot,
      ScheduleScreenViewModel model) {
    if (!snapshot.hasData) {
      return const Center(
        child: SizedBox(
          width: 70,
          height: 70,
          child: CircularProgressIndicator(),
        ),
      );
    }
    final headerFormatter = DateFormat.yMd('ru_RU');
    return Expanded(
      child: CustomScrollView(
        slivers: [
          if(model.state != ViewState.busy && !model.offline) SliverAppBar(
            leading: IconButton(
              onPressed: () async {
                await model.decrementWeek();
              },
              icon: const Icon(Icons.chevron_left_sharp),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  await model.incrementWeek();
                },
                icon: const Icon(Icons.chevron_right),
              )
            ],
            centerTitle: true,
            title: Text(
                '${headerFormatter.format(model.displayedWeek.start)} - ${headerFormatter.format(model.displayedWeek.end)}'),
            backgroundColor: theme.colorScheme.background,
            surfaceTintColor: Colors.transparent,
            pinned: true,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var formatedDate = DateFormat.yMMMMEEEEd('ru_RU').format(
                    model.displayedWeek.start.add(Duration(
                        days: snapshot.data!.keys.elementAt(index) - 1)));
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      formatedDate,
                      style: theme.textTheme.titleLarge,
                    ),
                    for (int i = 0;
                        i < snapshot.data!.values.elementAt(index).length;
                        i++)
                      ScheduleItemNormal(
                          subject: snapshot.data!.values.elementAt(index)[i],
                          even: i % 2 == 0),
                    if (index == snapshot.data!.length - 1)
                      const SizedBox(
                        height: 80,
                      )
                  ],
                );
              },
              childCount: snapshot.data!.length,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
