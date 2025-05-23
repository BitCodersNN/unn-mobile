// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/schedule/schedule_screen_view_model.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/widgets/schedule_tab.dart';
import 'package:unn_mobile/ui/widgets/offline_overlay_displayer.dart';

class ScheduleScreenView extends StatefulWidget {
  final int routeIndex;
  const ScheduleScreenView({super.key, required this.routeIndex});

  @override
  State<ScheduleScreenView> createState() => _ScheduleScreenViewState();
}

class _ScheduleScreenViewState extends State<ScheduleScreenView>
    with SingleTickerProviderStateMixin {
  static const Map<IdType, String> _tabTexts = {
    IdType.student: 'Студент',
    IdType.lecturer: 'Преподаватель',
    IdType.group: 'Группа',
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
    return OfflineOverlayDisplayer(
      child: BaseView<ScheduleScreenViewModel>(
        model: _viewModel,
        builder: (context, model, _) {
          final expanded = _createExpanded(model);
          return Scaffold(
            appBar: AppBar(
              title: const Text('Расписание'),
              leading: parentScaffold?.hasDrawer == true
                  ? IconButton(
                      onPressed: parentScaffold?.openDrawer,
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
                        for (final idType in model.tabIdTypes)
                          Tab(
                            text: _tabTexts[idType],
                          ),
                      ],
                      controller: _tabController,
                      onTap: (value) => model.selectedTab = value,
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
      ),
    );
  }

  Expanded _createExpanded(ScheduleScreenViewModel model) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          for (int i = 0; i < model.tabIdTypes.length; i++)
            ScheduleTab(model.tabIdTypes[i], model.tabViewModels[i]),
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
