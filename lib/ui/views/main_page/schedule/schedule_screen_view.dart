// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_range_type.dart';
import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';
import 'package:unn_mobile/core/models/schedule/schedule_search_suggestion_item.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/export_schedule_service.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/schedule/schedule_screen_view_model.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/main_page.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/schedule_tab_view.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/widgets/schedule_search_suggestion_item_view.dart';
import 'package:unn_mobile/ui/widgets/dialogs/message_dialog.dart';
import 'package:unn_mobile/ui/widgets/offline_overlay_displayer.dart';

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

  final SearchController _searchController = SearchController();
  bool _searchOpen = false;
  List<ScheduleSearchSuggestionItem> _suggestions = const [];
  bool _suggestionsLoading = false;
  int _searchRequestId = 0;
  Object? _suggestionsTab;

  static final DateTime _semesterStart = DateTime(2026, 8, 31);

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
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (!_searchOpen) {
      return;
    }
    setState(() {});
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final requestId = ++_searchRequestId;
    final tab = _viewModel.currentTab;
    setState(() {
      _suggestionsLoading = true;
      _suggestionsTab = tab;
    });
    final suggestions = (await tab?.getSuggestions(_searchController.text)) ??
        const <ScheduleSearchSuggestionItem>[];
    if (requestId == _searchRequestId && mounted) {
      setState(() {
        _suggestions = suggestions;
        _suggestionsLoading = false;
      });
    }
  }

  void _openSearch() {
    setState(() {
      _searchOpen = true;
      _suggestions = const [];
      _suggestionsTab = null;
    });
    _loadSuggestions();
  }

  void _closeSearch() {
    setState(() {
      _searchOpen = false;
      _suggestions = const [];
      _suggestionsLoading = false;
      _suggestionsTab = null;
    });
    _searchController.clear();
  }

  void _applySuggestion(ScheduleSearchSuggestionItem suggestion) {
    _closeSearch();
    _viewModel.currentTab?.applySearchSuggestion(suggestion);
  }

  static String _shortName(String full) => full
      .split(' ')
      .where((s) => s.isNotEmpty)
      .indexed
      .map((p) => p.$1 == 0 ? p.$2 : '${p.$2[0]}.')
      .join(' ');

  int _weekNumber(ScheduleScreenViewModel model) {
    // TODO: Переделать логику номера недели
    final week =
        model.selectedTimeRange.start.difference(_semesterStart).inDays ~/ 7 +
            1;
    return week < 1 ? 1 : week;
  }

  Widget _buildSubtitle(BuildContext context, ScheduleScreenViewModel model) {
    final theme = Theme.of(context);
    final foundName = model.currentTab?.foundName;
    if (foundName == null) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            _shortName(foundName),
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: () => model.currentTab?.clearSearch(),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Icon(
              Icons.close,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Группа, фамилия...',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              tooltip: 'Очистить',
              onPressed: _searchController.clear,
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsOverlay(
    BuildContext context,
    ScheduleScreenViewModel model,
  ) {
    final theme = Theme.of(context);
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      bottom: 8,
      child: LayoutBuilder(
        builder: (context, constraints) => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight),
            child: Material(
              color: theme.colorScheme.surface,
              elevation: 6,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: _suggestionsLoading && _suggestions.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : _suggestions.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Ничего не найдено',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: _suggestions.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            thickness: 1,
                            color: theme.dividerColor.withAlpha(51),
                          ),
                          itemBuilder: (context, index) {
                            final suggestion = _suggestions[index];
                            return ScheduleSearchSuggestionItemView(
                              model: suggestion,
                              searchType: model.selectedUser,
                              query: _searchController.text,
                              onSelected: () => _applySuggestion(suggestion),
                            );
                          },
                        ),
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _exportMenuItem({
    required String value,
    required IconData icon,
    required String title,
    required bool enabled,
    required ThemeData theme,
    String? subtitle,
  }) =>
      PopupMenuItem<String>(
        value: value,
        enabled: enabled,
        height: subtitle == null ? 48 : 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.38,
          child: Row(
            children: [
              Icon(icon, size: 24, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  List<PopupMenuEntry<String>> _exportMenuItems(
    ThemeData theme,
    bool canExport,
  ) =>
      [
        PopupMenuItem<String>(
          enabled: false,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              'Экспорт расписания',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const PopupMenuDivider(height: 9),
        _exportMenuItem(
          value: 'calendar',
          icon: Icons.calendar_month,
          title: 'Экспорт в календарь',
          enabled: canExport,
          theme: theme,
        ),
      ];

  Future<void> _showExportMenu(
    BuildContext buttonContext,
    ScheduleScreenViewModel model,
    bool online,
  ) async {
    final renderBox = buttonContext.findRenderObject()! as RenderBox;
    final buttonRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
    final screenSize = MediaQuery.of(buttonContext).size;
    final theme = Theme.of(buttonContext);
    final canExport = online && (model.currentTab?.hasAnyId ?? false);

    const menuWidth = 300.0;
    final menuRight = buttonRect.right.clamp(12.0, screenSize.width - 12.0);
    final menuLeft = menuRight - menuWidth;
    final menuTop =
        (buttonRect.bottom + 4.0).clamp(12.0, screenSize.height - 12.0);

    final anchorFraction =
        ((buttonRect.center.dx - menuLeft) / menuWidth).clamp(0.0, 1.0);
    final scaleAlignment = Alignment(anchorFraction * 2 - 1, -1.0);

    final value = await showGeneralDialog<String>(
      context: buttonContext,
      barrierDismissible: true,
      barrierLabel:
          MaterialLocalizations.of(buttonContext).modalBarrierDismissLabel,
      barrierColor: Colors.black.withAlpha(80),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) => Stack(
        children: [
          Positioned(
            top: menuTop,
            right: screenSize.width - menuRight,
            width: menuWidth,
            child: FadeTransition(
              opacity:
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: ScaleTransition(
                scale:
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                alignment: scaleAlignment,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: screenSize.height - menuTop - 8.0,
                  ),
                  child: SingleChildScrollView(
                    child: Material(
                      color: theme.colorScheme.surface,
                      elevation: 6,
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _exportMenuItems(theme, canExport),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (value == null || !mounted) {
      return;
    }
    _onExportMenuSelected(context, model, value);
  }

  void _onExportMenuSelected(
    BuildContext context,
    ScheduleScreenViewModel model,
    String value,
  ) {
    switch (value) {
      case 'calendar':
        exportScheduleCallback(context, model);
        break;
    }
  }

  @override
  Widget build(BuildContext context) => OfflineOverlayDisplayer(
        child: BaseView<ScheduleScreenViewModel>(
          builder: (context, model, _) {
            if (_searchOpen && _suggestionsTab != model.currentTab) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _searchOpen) {
                  _loadSuggestions();
                }
              });
            }

            return OnlineStatusBuilder(
              builder: (context, online) => DefaultTabController(
                length: model.sortedUserTypeList.length,
                initialIndex: 0,
                child: Scaffold(
                  appBar: AppBar(
                    leading: _searchOpen
                        ? IconButton(
                            icon: const Icon(Icons.arrow_back),
                            tooltip: 'Закрыть поиск',
                            onPressed: _closeSearch,
                          )
                        : getSubpageLeading(widget.bottomRouteIndex),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Расписание'),
                        AnimatedBuilder(
                          animation: model.currentTab ?? model,
                          builder: (context, _) =>
                              _buildSubtitle(context, model),
                        ),
                      ],
                    ),
                    forceMaterialTransparency: true,
                    actions: [
                      if (online && !_searchOpen)
                        IconButton(
                          icon: const Icon(Icons.search),
                          tooltip: 'Поиск',
                          onPressed: _openSearch,
                        ),
                      if (!_searchOpen)
                        Builder(
                          builder: (buttonContext) => IconButton(
                            icon: const Icon(Icons.more_vert),
                            tooltip: 'Экспорт расписания',
                            onPressed: () =>
                                _showExportMenu(buttonContext, model, online),
                          ),
                        ),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(95.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (_searchOpen)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child: _buildSearchField(context),
                              )
                            else if (_searchOpen)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child: _buildSearchField(context),
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
                                      text: 'неделя ${_weekNumber(model)}',
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
                                  .map((t) => Tab(text: t.getDisplayName()))
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
                                onSearchRequested: _openSearch,
                              ),
                            )
                            .toList(),
                      ),
                      if (_searchOpen) ...[
                        GestureDetector(
                          onTap: _closeSearch,
                          child: Container(
                            color: Colors.black.withAlpha(80),
                          ),
                        ),
                        if (_suggestions.isNotEmpty ||
                            _suggestionsLoading ||
                            _searchController.text.isNotEmpty)
                          _buildSuggestionsOverlay(context, model),
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

  void exportScheduleCallback(
    BuildContext context,
    ScheduleScreenViewModel model,
  ) async {
    final permission = await model.askForExportPermission();

    if (permission == RequestCalendarPermissionResult.permanentlyDenied) {
      if (context.mounted) {
        final result = await showOkCancelAlertDialog(
          context: context,
          title: 'Доступ к календарю',
          message:
              'Приложению запрещён доступ к календарю. Разрешите его в настройках, чтобы экспортировать расписание.',
          okLabel: 'Настройки',
          cancelLabel: 'Отмена',
        );

        if (result == OkCancelResult.ok && context.mounted) {
          await model.openSettingsWindow();
        }
      }
    } else if (permission == RequestCalendarPermissionResult.allowed) {
      if (!context.mounted) {
        return;
      }

      final actions = DateTimeRangeType.values
          .map(
            (type) => AlertDialogAction<DateTimeRangeType>(
              key: type,
              label: type.label,
              isDefaultAction: type == DateTimeRangeType.untilEndOfWeek,
            ),
          )
          .toList();

      final selectedType = await showConfirmationDialog<DateTimeRangeType>(
        context: context,
        title: 'Экспортировать расписание',
        actions: actions,
        cancelLabel: 'Отмена',
      );

      if (selectedType != null) {
        final bool result = await model.exportSchedule(selectedType);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Экспорт завершён'),
            ),
          );
        }

        if (Platform.isAndroid && context.mounted) {
          await showMessage(
            context,
            result
                ? 'Расписание экспортировано в календарь "Расписание ННГУ". \n'
                    'Возможно, понадобится включить настройку Device Calendar в приложении календаря.'
                : 'Не удалось экспортировать. Попробуйте снова.',
            messageKey: result ? 'export_schedule_success' : null,
          );
        }
      }
    }
  }
}
