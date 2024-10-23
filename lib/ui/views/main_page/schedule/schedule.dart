import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/schedule_screen_view_model.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/widgets/schedule_tab.dart';

class ScheduleScreenView extends StatefulWidget {
  final int routeIndex;
  const ScheduleScreenView({super.key, required this.routeIndex});

  @override
  State<ScheduleScreenView> createState() => _ScheduleScreenViewState();
}

class _ScheduleScreenViewState extends State<ScheduleScreenView>
    with SingleTickerProviderStateMixin {
  Map<IDType, String> tabTexts = {
    IDType.student: 'Студент',
    IDType.lecturer: 'Преподаватель',
    IDType.group: 'Группа',
  };

  late TabController _tabController;
  late ScheduleScreenViewModel _viewModel;

  @override
  void initState() {
    _viewModel = Injector.appInstance
        .get<MainPageRoutesViewModelsFactory>()
        .getViewModelByRouteIndex<ScheduleScreenViewModel>(widget.routeIndex);

    _tabController = TabController(
      initialIndex: _viewModel.selectedTab,
      length: 3,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final parentScaffold = Scaffold.maybeOf(context);
    return BaseView<ScheduleScreenViewModel>(
      model: _viewModel,
      builder: (context, model, _) {
        final expanded = _createExpanded(model);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Расписание'),
            leading: parentScaffold?.hasDrawer ?? false
                ? IconButton(
                    onPressed: () {
                      parentScaffold?.openDrawer();
                    },
                    icon: const Icon(Icons.menu),
                  )
                : null,
          ),
          body: OnlineStatusBuilder(
            onlineWidget: Column(
              children: [
                MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1.5,
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.label,
                    tabAlignment: TabAlignment.center,
                    isScrollable: true,
                    tabs: [
                      for (final idType in model.tabIDTypes)
                        Tab(
                          text: tabTexts[idType],
                        ),
                    ],
                    controller: _tabController,
                    onTap: (value) {
                      model.selectedTab = value;
                    },
                  ),
                ),
                expanded,
              ],
            ),
            offlineWidget: Column(
              children: [
                expanded,
              ],
            ),
          ),
        );
      },
      onModelReady: (p0) => p0.init(),
    );
  }

  Expanded _createExpanded(ScheduleScreenViewModel model) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          for (int i = 0; i < model.tabIDTypes.length; i++)
            ScheduleTab(model.tabIDTypes[i], model.tabViewModels[i]),
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
