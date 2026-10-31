// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/misc/html_utils/html_to_plain_text.dart';
import 'package:unn_mobile/core/models/feed/feed_filter.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_post_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_screen_view_model.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_filter_swipe.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_filters_bar.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_posts_sliver.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_tab_state.dart';
import 'package:unn_mobile/ui/widgets/empty_state_widget.dart';
import 'package:unn_mobile/ui/widgets/offline_overlay_displayer.dart';
import 'package:unn_mobile/ui/widgets/search/search_controller.dart';
import 'package:unn_mobile/ui/widgets/search/search_field.dart';

class FeedScreenView extends StatefulWidget {
  const FeedScreenView({super.key});

  @override
  State<FeedScreenView> createState() => FeedScreenViewState();
}

class FeedScreenViewState extends State<FeedScreenView>
    implements MainPageTabState {
  final Map<FeedFilter, ScrollController> _scrollControllers = {};

  ScrollController get _scrollController =>
      _scrollControllers.putIfAbsent(_viewModel.filter, () {
        final filter = _viewModel.filter;
        final controller = ScrollController(
          initialScrollOffset: _viewModel.scrollPosition,
        );
        controller.addListener(() {
          if (_viewModel.filter == filter && controller.positions.length == 1) {
            _viewModel.scrollPosition = controller.offset;
          }
        });
        return controller;
      });
  late final AppSearchController<String> _search;
  late final FeedScreenViewModel _viewModel;
  bool _clearingSearch = false;
  FeedFilter? _previewFilter;
  String? _scrollQuery;

  @override
  void initState() {
    super.initState();
    _viewModel = context
        .read<MainPageRoutesViewModelsFactory>()
        .getOrCreate<FeedScreenViewModel>();
    _search = AppSearchController<String>(loader: (_) async => [])
      ..addListener(_onSearchChanged);
    _search.textController.text = _viewModel.searchQuery ?? '';
    _scrollQuery = _viewModel.searchQuery;
    _viewModel.scrollToTop = refreshTab;
    _viewModel.onRefresh = refreshTab;
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _openSearch() {
    triggerHaptic(HapticIntensity.light);
    refreshTab();
    _search.textController.text = _viewModel.searchQuery ?? '';
    _search.open();
  }

  void _closeSearch() {
    _search.close();
    _search.textController.text = _viewModel.searchQuery ?? '';
  }

  void _clearSearch() {
    if (_viewModel.isBusy || _viewModel.loadingMore) {
      return;
    }
    _search.clearQuery();
    unawaited(_submitSearch(''));
  }

  Future<void> _submitSearch(String query) async {
    if (_viewModel.isBusy || _viewModel.loadingMore) {
      return;
    }
    triggerHaptic(HapticIntensity.light);
    FocusScope.of(context).unfocus();
    refreshTab();
    final clearing = query.trim().isEmpty;
    if (clearing) {
      setState(() => _clearingSearch = true);
    }
    try {
      if (clearing) {
        if (_viewModel.hasSearch) {
          await _viewModel.resetSearch();
        }
      } else {
        await _viewModel.submitSearch(query);
      }
    } finally {
      if (mounted) {
        if (_scrollQuery != _viewModel.searchQuery) {
          _scrollQuery = _viewModel.searchQuery;
          for (final controller in _scrollControllers.values) {
            if (controller.hasClients) {
              controller.jumpTo(0);
            }
          }
        }
        _closeSearch();
        setState(() => _clearingSearch = false);
      }
    }
  }

  void _previewFilterChanged(FeedFilter filter) {
    final preview = filter == _viewModel.filter ? null : filter;
    if (_previewFilter != preview) {
      setState(() => _previewFilter = preview);
    }
  }

  Future<FeedFilter> _selectFilter(FeedFilter filter) async {
    if (_viewModel.isBusy ||
        _viewModel.loadingMore ||
        filter == _viewModel.filter) {
      return _viewModel.filter;
    }
    _previewFilterChanged(filter);
    triggerHaptic(HapticIntensity.selection);
    try {
      await _viewModel.setFilter(filter);
    } finally {
      if (mounted) {
        setState(() => _previewFilter = null);
      }
    }
    return _viewModel.filter;
  }

  List<FeedPostViewModel> _visiblePosts(
    FeedScreenViewModel model,
    bool online,
  ) {
    var posts = model.filter == FeedFilter.pinned
        ? model.pinnedPosts
        : online
        ? model.posts
        : model.offlinePosts;
    if (model.filter == FeedFilter.important) {
      posts = posts.where((post) => post.isAnnouncement).toList();
    }
    if (model.filter == FeedFilter.pinned && model.hasSearch) {
      final query = model.searchQuery!.toLowerCase();
      posts = posts
          .where(
            (post) =>
                htmlToPlainText(post.postText).toLowerCase().contains(query) ||
                (post.profileViewModel?.fullname.toLowerCase().contains(
                      query,
                    ) ??
                    false),
          )
          .toList();
    }
    return posts;
  }

  @override
  Widget build(BuildContext context) => OfflineOverlayDisplayer(
    child: OnlineStatusBuilder(
      builder: (context, online) => BaseView<FeedScreenViewModel>(
        model: _viewModel,
        onModelReady: (model) => model.init(),
        builder: (context, model, _) {
          final theme = Theme.of(context);
          return Scaffold(
            backgroundColor: theme.colorScheme.surfaceContainerLow,
            appBar: AppBar(
              backgroundColor: theme.colorScheme.surfaceContainerLow,
              scrolledUnderElevation: 0,
              toolbarHeight: 12 + MediaQuery.textScalerOf(context).scale(48),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat(
                      'EEEE, d MMMM',
                      'ru_RU',
                    ).format(DateTime.now()).toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Лента',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              automaticallyImplyLeading: false,
              actions: [
                if (!_search.isOpen && !model.hasSearch)
                  IconButton(
                    onPressed: online && !model.isBusy && !model.loadingMore
                        ? _openSearch
                        : null,
                    tooltip: 'Поиск по ленте',
                    icon: const Icon(Icons.search_rounded),
                  ),
              ],
            ),
            body: Column(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: FeedFiltersBar(
                      selected: _previewFilter ?? model.filter,
                      onSelected: online && !model.isBusy && !model.loadingMore
                          ? _selectFilter
                          : null,
                    ),
                  ),
                ),
                Expanded(child: _feedBody(context, model, online)),
              ],
            ),
          );
        },
      ),
    ),
  );

  Widget _feedBody(
    BuildContext context,
    FeedScreenViewModel model,
    bool online,
  ) {
    final filter = model.filter;
    final posts = _visiblePosts(model, online);
    final colors = Theme.of(context).colorScheme;
    final canSelectFilter = online && !model.isBusy && !model.loadingMore;
    return FeedFilterSwipe(
      selected: model.filter,
      enabled: canSelectFilter,
      onSelected: _selectFilter,
      onPreviewChanged: _previewFilterChanged,
      cacheKey: model.searchQuery,
      isChangingFilter: model.isReplacingPosts && _previewFilter != null,
      child: PrimaryScrollController(
        controller: _scrollController,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: NotificationListener<ScrollEndNotification>(
              onNotification: (notification) {
                if (online &&
                    filter == model.filter &&
                    notification.metrics.axis == Axis.vertical &&
                    !model.isBusy &&
                    model.filter != FeedFilter.pinned &&
                    notification.metrics.extentAfter < 300) {
                  unawaited(model.loadMorePosts());
                }
                return false;
              },
              child: RefreshIndicator.adaptive(
                onRefresh: () async {
                  if (online) {
                    triggerHaptic(HapticIntensity.light);
                    await model.reload();
                  }
                },
                child: CustomScrollView(
                  primary: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    if (!_clearingSearch && (_search.isOpen || model.hasSearch))
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: SearchField<String>(
                            controller: _search,
                            hintText: 'Поиск по ленте',
                            onSubmitted: _submitSearch,
                            onClear: _clearSearch,
                            autofocus: _search.isOpen,
                          ),
                        ),
                      ),
                    if (model.failedToLoad)
                      _notice(
                        'Не удалось обновить ленту. Потяните вниз, чтобы повторить.',
                        colors.error,
                      ),
                    if (!online && posts.isNotEmpty)
                      _notice(
                        'Показаны последние загруженные посты',
                        colors.onSurfaceVariant,
                      ),
                    if (model.isReplacingPosts || posts.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child:
                            model.isReplacingPosts ||
                                model.isBusy ||
                                (online && model.loadingMore)
                            ? const Center(
                                child: CircularProgressIndicator.adaptive(),
                              )
                            : EmptyStateWidget(
                                icon: model.hasSearch
                                    ? Icons.search_off_rounded
                                    : Icons.article_outlined,
                                title: model.hasSearch
                                    ? 'Ничего не найдено'
                                    : switch (model.filter) {
                                        FeedFilter.pinned =>
                                          'Нет закреплённых постов',
                                        FeedFilter.important =>
                                          'Нет важных сообщений',
                                        FeedFilter.all => 'Пока нет постов',
                                      },
                                caption: model.hasSearch
                                    ? 'Попробуйте другой запрос'
                                    : !online
                                    ? 'Подключитесь к сети, чтобы загрузить ленту'
                                    : 'Потяните вниз, чтобы обновить ленту',
                              ),
                      )
                    else
                      FeedPostsSliver(
                        posts: posts,
                        showCount: model.filter == FeedFilter.pinned,
                        title: model.hasSearch
                            ? 'Результаты поиска'
                            : model.filter == FeedFilter.all
                            ? null
                            : model.filter.caption,
                      ),
                    if ((model.loadingMore || model.isBusy) &&
                        !model.isReplacingPosts &&
                        posts.isNotEmpty &&
                        online)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: SizedBox.square(
                              dimension: 24,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _notice(String message, Color color) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Text(message, style: TextStyle(color: color)),
    ),
  );

  @override
  void dispose() {
    if (_viewModel.scrollToTop == refreshTab) {
      _viewModel.scrollToTop = null;
    }
    if (_viewModel.onRefresh == refreshTab) {
      _viewModel.onRefresh = null;
    }
    _search
      ..removeListener(_onSearchChanged)
      ..dispose();
    for (final controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void refreshTab() {
    if (_scrollController.hasClients) {
      unawaited(
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        ),
      );
    }
  }
}
