// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unn_mobile/core/constants/main_page_paths.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/models/profile/profile_search_mode.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/people/people_screen_view_model.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/people/widgets/person_search_tile.dart';
import 'package:unn_mobile/ui/widgets/empty_state_widget.dart';
import 'package:unn_mobile/ui/widgets/mode_tab_bar.dart';
import 'package:unn_mobile/ui/widgets/offline_overlay_displayer.dart';
import 'package:unn_mobile/ui/widgets/search/search_backdrop.dart';
import 'package:unn_mobile/ui/widgets/search/search_input.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen>
    with SingleTickerProviderStateMixin {
  late final PeopleScreenViewModel _model;
  late final TextEditingController _search;
  late final TabController _tabs;
  final FocusNode _searchFocus = FocusNode();
  final Map<ProfileSearchMode, ScrollController> _scrolls = {
    for (final mode in ProfileSearchMode.values) mode: ScrollController(),
  };
  int _queryVersion = 0;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(_searchFocusChanged);
    _model = context
        .read<MainPageRoutesViewModelsFactory>()
        .getOrCreate<PeopleScreenViewModel>();
    _search = TextEditingController(text: _model.query)
      ..addListener(_queryChanged);
    _tabs = TabController(
      length: ProfileSearchMode.values.length,
      initialIndex: ProfileSearchMode.values.indexOf(_model.mode),
      vsync: this,
    )..addListener(_tabChanged);
    for (final entry in _scrolls.entries) {
      entry.value.addListener(() => _loadMore(entry.key));
    }
  }

  void _searchFocusChanged() => setState(() {});

  void _queryChanged() {
    if (_model.query == _search.text.trim()) {
      return;
    }
    _queryVersion++;
    _model.updateQuery(_search.text);
    for (final scroll in _scrolls.values) {
      if (scroll.hasClients) {
        scroll.jumpTo(0);
      }
    }
  }

  void _loadMore(ProfileSearchMode mode) {
    final scroll = _scrolls[mode]!;
    if (mode == _model.mode &&
        scroll.hasClients &&
        scroll.position.extentAfter < 300 &&
        !_model.pageFor(mode).hasMoreError) {
      unawaited(_model.loadMore(mode: mode));
    }
  }

  void _tabChanged() {
    final mode = ProfileSearchMode.values[_tabs.index];
    if (mode != _model.mode) {
      triggerHaptic(HapticIntensity.selection);
      _model.selectMode(mode);
    }
  }

  @override
  void dispose() {
    _search.removeListener(_queryChanged);
    _search.dispose();
    _searchFocus
      ..removeListener(_searchFocusChanged)
      ..dispose();
    _tabs.dispose();
    for (final scroll in _scrolls.values) {
      scroll.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OfflineOverlayDisplayer(
    child: BaseView<PeopleScreenViewModel>(
      model: _model,
      builder: (context, model, _) {
        final colors = Theme.of(context).colorScheme;
        return Scaffold(
          backgroundColor: colors.surfaceContainerLow,
          appBar: AppBar(
            title: const Text('Поиск людей'),
            centerTitle: false,
            backgroundColor: colors.surfaceContainerLow,
            scrolledUnderElevation: 0,
          ),
          body: SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: SearchInput(
                        controller: _search,
                        focusNode: _searchFocus,
                        autofocus: false,
                        hintText: 'Фамилия или имя',
                        onSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                          model.submit();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ModeTabBar(
                        controller: _tabs,
                        isScrollable: false,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labels: ProfileSearchMode.values
                            .map((mode) => mode.label)
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _searchFocus.unfocus,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            TabBarView(
                              controller: _tabs,
                              children: [
                                for (final mode in ProfileSearchMode.values)
                                  KeyedSubtree(
                                    key: ValueKey(mode),
                                    child: _results(context, model, mode),
                                  ),
                              ],
                            ),
                            Positioned.fill(
                              child: SearchBackdrop(
                                visible: _searchFocus.hasFocus,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _results(
    BuildContext context,
    PeopleScreenViewModel model,
    ProfileSearchMode mode,
  ) {
    final page = model.pageFor(mode);
    if (model.query.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.person_search_outlined,
        title: mode == ProfileSearchMode.students
            ? 'Поиск студентов'
            : 'Поиск сотрудников',
        caption: 'Введите фамилию или имя, чтобы найти человека и открыть его профиль',
      );
    }
    if (page.isSearching || !page.hasLoaded) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (page.hasError) {
      return Column(
        children: [
          const Expanded(
            child: EmptyStateWidget(
              icon: Icons.cloud_off_outlined,
              title: 'Не удалось выполнить поиск',
              caption: 'Проверьте подключение к интернету и попробуйте ещё раз',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: TextButton.icon(
              onPressed: () => model.submit(mode: mode),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Повторить'),
            ),
          ),
        ],
      );
    }
    if (page.people.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.search_off_rounded,
        title: 'Никого не найдено',
        caption: 'Попробуйте изменить запрос или выбрать другой режим поиска',
      );
    }
    return CustomScrollView(
      key: PageStorageKey('people-${mode.name}-$_queryVersion'),
      controller: _scrolls[mode],
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              'Найдено: ${page.total}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.builder(
            itemCount: page.people.length,
            itemBuilder: (context, index) {
              final person = page.people[index];
              return Padding(
                key: ValueKey(person.userId),
                padding: const EdgeInsets.only(bottom: 8),
                child: PersonSearchTile(
                  person: person,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    final location = AppRouter.of(context)
                        .locationFor(MainPagePaths.people);
                    unawaited(
                      context.push<void>('$location/profile/${person.userId}'),
                    );
                  },
                ),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: page.isLoadingMore
                ? const Center(
                    child: SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  )
                : page.hasMore
                ? Center(
                    child: TextButton(
                      onPressed: () => model.loadMore(mode: mode),
                      child: Text(
                        page.hasMoreError
                            ? 'Не удалось загрузить. Повторить'
                            : 'Загрузить ещё',
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
