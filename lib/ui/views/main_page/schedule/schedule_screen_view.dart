// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';
import 'package:unn_mobile/core/models/schedule/schedule_search_suggestion_item.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/schedule/schedule_screen_view_model.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/main_page.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/export_schedule_flow.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/schedule_tab_view.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/widgets/export_menu_button.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/widgets/schedule_search_suggestion_item_view.dart';
import 'package:unn_mobile/ui/widgets/offline_overlay_displayer.dart';
import 'package:unn_mobile/ui/widgets/search/search_controller.dart';
import 'package:unn_mobile/ui/widgets/search/search_field.dart';
import 'package:unn_mobile/ui/widgets/search/search_overlay.dart';

class ScheduleScreenView extends StatefulWidget {
  final int? bottomRouteIndex;
  const ScheduleScreenView({
    super.key,
    this.bottomRouteIndex,
  });

  @override
  State<ScheduleScreenView> createState() => _ScheduleScreenViewState();
}

class _ScheduleScreenViewState extends State<ScheduleScreenView> {
  late ScheduleScreenViewModel _viewModel;
  late AppSearchController<ScheduleSearchSuggestionItem> _search;

  Object? _suggestionsTab;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.bottomRouteIndex == null
        ? Injector.appInstance.get<ScheduleScreenViewModel>()
        : Injector.appInstance
            .get<MainPageRoutesViewModelsFactory>()
            .getViewModelByRouteIndex<ScheduleScreenViewModel>(
              widget.bottomRouteIndex!,
            );
    _search = AppSearchController<ScheduleSearchSuggestionItem>(
      loader: (query) async =>
          (await _viewModel.currentTab?.getSuggestions(query)) ??
          const <ScheduleSearchSuggestionItem>[],
      applier: (suggestion) =>
          _viewModel.currentTab?.applySearchSuggestion(suggestion),
    );
    _search.addListener(_onSearchNotify);
  }

  @override
  void dispose() {
    _search
      ..removeListener(_onSearchNotify)
      ..dispose();
    super.dispose();
  }

  void _onSearchNotify() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => OfflineOverlayDisplayer(
        child: BaseView<ScheduleScreenViewModel>(
          builder: (context, model, _) {
            if (_search.isOpen && _suggestionsTab != model.currentTab) {
              _suggestionsTab = model.currentTab;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _search.isOpen) {
                  _search.loadSuggestions();
                }
              });
            }

            return OnlineStatusBuilder(
              builder: (context, online) => DefaultTabController(
                length: model.sortedUserTypeList.length,
                initialIndex: 0,
                child: Scaffold(
                  appBar: AppBar(
                    leading: _search.isOpen
                        ? IconButton(
                            icon: const Icon(Icons.arrow_back),
                            tooltip: 'Закрыть поиск',
                            onPressed: _search.close,
                          )
                        : getSubpageLeading(widget.bottomRouteIndex),
                    title: const Text('Расписание'),
                    forceMaterialTransparency: true,
                    actions: [
                      if (online && !_search.isOpen)
                        IconButton(
                          icon: const Icon(Icons.search),
                          tooltip: 'Поиск',
                          onPressed: _search.open,
                        ),
                      if (!_search.isOpen)
                        ExportMenuButton(
                          enabled: online && model.canExport,
                          onSelected: (value) {
                            if (value == 'calendar') {
                              runExportFlow(context, model);
                            }
                          },
                        ),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(95.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (_search.isOpen)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child:
                                    SearchField<ScheduleSearchSuggestionItem>(
                                  controller: _search,
                                  hintText: 'Группа, фамилия, предмет...',
                                ),
                              )
                            else ...[
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: online
                                        ? () {
                                            model.previousWeek();
                                          }
                                        : null,
                                    icon: const Icon(Icons.arrow_left),
                                    iconSize: 32.0,
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${model.selectedTimeRange.start.format(DatePattern.dMMMM)} - ${model.selectedTimeRange.end.format(DatePattern.dMMMM)}',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: online
                                        ? () {
                                            model.nextWeek();
                                          }
                                        : null,
                                    icon: const Icon(Icons.arrow_right),
                                    iconSize: 32.0,
                                  ),
                                ],
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'неделя ${model.weekNumber}',
                                    ),
                                    if (model.weekOffset == 0)
                                      TextSpan(
                                        text: ' · текущая',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                            TabBar(
                              tabAlignment: TabAlignment.center,
                              tabs: model.sortedUserTypeList
                                  .map((t) => Tab(text: t.getDisplayName))
                                  .toList(),
                              isScrollable: true,
                              onTap: (value) {
                                model.selectedUser =
                                    model.sortedUserTypeList[value];
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  body: Stack(
                    children: [
                      TabBarView(
                        children: model.sortedUserTypeList
                            .map(
                              (t) => ScheduleTabView(
                                key: ValueKey(t),
                                viewModel: model.modelsByType[t]!,
                                selectedTimeRange: model.selectedTimeRange,
                                weekOffset: model.weekOffset,
                                onSearchRequested: _search.open,
                              ),
                            )
                            .toList(),
                      ),
                      if (_search.isOpen) ...[
                        GestureDetector(
                          onTap: _search.close,
                          child: Container(
                            color: Colors.black.withAlpha(80),
                          ),
                        ),
                        if (_search.suggestions.isNotEmpty ||
                            _search.isLoading ||
                            _search.query.isNotEmpty)
                          SearchOverlay<ScheduleSearchSuggestionItem>(
                            controller: _search,
                            suggestionBuilder:
                                (context, suggestion, query, onTap) =>
                                    ScheduleSearchSuggestionItemView(
                              model: suggestion,
                              searchType: model.selectedUser,
                              query: query,
                              onSelected: onTap,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              statusChanged: (_) => Future.wait(
                model.modelsByType.values.map((t) async => await t.refresh()),
              ),
            );
          },
          model: _viewModel,
          onModelReady: (model) => model.init(),
        ),
      );
}
