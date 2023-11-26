import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:unn_mobile/core/misc/date_time_extensions.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/models/subject.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/schedule_screen_view_model.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/widgets/schedule_item_normal.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/widgets/schedule_search_suggestion_item.dart';

class ScheduleScreenView extends StatefulWidget {
  const ScheduleScreenView({super.key});

  @override
  State<ScheduleScreenView> createState() => _ScheduleScreenViewState();
}

class _ScheduleScreenViewState extends State<ScheduleScreenView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FocusNode _searchFocusNode;
  late AutoScrollController _scrollController;
  @override
  void initState() {
    _scrollController = AutoScrollController();
    _tabController = TabController(length: 3, vsync: this);
    _searchFocusNode = FocusNode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              _scheduleTab(theme, IDType.student),
              _scheduleTab(theme, IDType.group),
              _scheduleTab(theme, IDType.person),
            ],
          ),
        ),
      ],
    );
  }

  Widget _scheduleTab(ThemeData theme, IDType type) {
    return BaseView<ScheduleScreenViewModel>(
      builder: (context, model, child) {
        return Column(
          children: [
            SearchAnchor(
              builder: (context, controller) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SearchBar(
                    hintText: model.searchPlaceholderText,
                    leading: const Icon(Icons.search),
                    focusNode: _searchFocusNode,
                    trailing: [
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.more_horiz))
                    ],
                    shape: MaterialStateProperty.resolveWith(
                      (states) => const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    onTap: () => controller.openView(),
                    onChanged: (_) {
                      controller.openView();
                    },
                    onSubmitted: (value) async {
                      if (model.lastSearchQuery != value) {
                        await model.submitSearch(value);
                      }
                    },
                    controller: controller,
                  ),
                );
              },
              suggestionsBuilder: (context, controller) async {
                if (controller.text == '') {
                  final suggestions = model.getHistorySuggestions();
                  return suggestions.map((e) => ScheduleSearchSuggestionItem(itemName: e, onSelected: () {
                    controller.closeView(e);
                  },));
                } else {
                  final rawSuggestions =
                      await model.getSearchSuggestions(controller.text);
                  return rawSuggestions.map<ScheduleSearchSuggestionItem>(
                    (e) => ScheduleSearchSuggestionItem(
                      itemName: e.label,
                      itemDescription: e.description,
                      onSelected: () {
                        setState(() {
                          controller.closeView(e.label);
                          //_searchFocusNode.unfocus();
                          Future.delayed(
                            const Duration(milliseconds: 50),
                            () {
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');
                            },
                          );
                          model.lastSearchQuery = controller.text;
                          model.addHistoryItem(e.label);
                          model.selectedId = e.id;
                          model.updateFilter(e.id);
                        });
                      },
                    ),
                  );
                }
              },
            ),
            if (model.scheduleLoader != null)
              FutureBuilder(
                builder: (context, snapshot) {
                  return _customScrollView(theme, snapshot, model);
                },
                future: model.scheduleLoader,
              ),
          ],
        );
      },
      onModelReady: (model) {
        model.init(
          type,
          onScheduleLoaded: (schedule) async {
            int todayScheduleIndex = -1;
            for (int i = 0; i < schedule.values.length; i++) {
              if (schedule.values
                  .elementAt(i)[0]
                  .dateTimeRange
                  .start
                  .isSameDate(DateTime.now())) {
                todayScheduleIndex = i;
                break;
              }
            }
            if (model.displayedWeekOffset == 0 && todayScheduleIndex != -1) {
              await _scrollController.scrollToIndex(todayScheduleIndex,
                  preferPosition: AutoScrollPosition.begin);
            } else {
              await _scrollController.scrollToIndex(0);
            }
          },
        );
      },
    );
  }

  Widget _customScrollView(
      ThemeData theme,
      AsyncSnapshot<Map<int, List<Subject>>> snapshot,
      ScheduleScreenViewModel model) {
    if (!snapshot.hasData) {
      return const Expanded(
        child: Center(
          child: SizedBox(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    final headerFormatter = DateFormat.yMd('ru_RU');
    final extraColors = theme.extension<UnnMobileColors>()!;

    return Expanded(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          if (model.state != ViewState.busy && !model.offline)
            SliverAppBar(
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
                ),
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
                var formatedDate = DateFormat.MMMMEEEEd('ru_RU').format(
                  model.displayedWeek.start.add(
                    Duration(days: snapshot.data!.keys.elementAt(index) - 1),
                  ),
                );

                return AutoScrollTag(
                  key: ValueKey(index),
                  controller: _scrollController,
                  index: index,
                  child: Container(
                    decoration: BoxDecoration(
                        color: (snapshot.data!.values
                                .elementAt(index)
                                .first
                                .dateTimeRange
                                .start
                                .isSameDate(DateTime.now()))
                            ? extraColors.scheduleDayHighlight
                            : null),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            formatedDate,
                            textAlign: TextAlign.left,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        for (int i = 0;
                            i < snapshot.data!.values.elementAt(index).length;
                            i++)
                          ScheduleItemNormal(
                              subject:
                                  snapshot.data!.values.elementAt(index)[i],
                              even: i % 2 == 0),
                        if (index == snapshot.data!.length - 1)
                          const SizedBox(
                            height: 80,
                          )
                      ],
                    ),
                  ),
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
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
