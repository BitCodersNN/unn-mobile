// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_screen_view_model.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_post.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_tab_state.dart';
import 'package:unn_mobile/ui/widgets/offline_overlay_displayer.dart';

class FeedScreenView extends StatefulWidget {
  final int routeIndex;
  const FeedScreenView({super.key, required this.routeIndex});

  @override
  State<FeedScreenView> createState() => FeedScreenViewState();
}

class FeedScreenViewState extends State<FeedScreenView>
    implements MainPageTabState {
  late ScrollController _scrollController;

  late FeedScreenViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = Injector.appInstance
        .get<MainPageRoutesViewModelsFactory>()
        .getViewModelByRouteIndex<FeedScreenViewModel>(widget.routeIndex);

    _scrollController = ScrollController(
      initialScrollOffset: _viewModel.scrollPosition,
      keepScrollOffset: true,
    );

    _viewModel.scrollToTop = () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: Durations.medium1,
          curve: Curves.decelerate,
        );
      }
    };
    _viewModel.onRefresh = () => refreshTab();
    _scrollController.addListener(scrollUpdate);
  }

  void scrollUpdate() {
    _viewModel.scrollPosition = _scrollController.offset;
  }

  @override
  Widget build(BuildContext context) {
    final parentScaffold = Scaffold.maybeOf(context);
    final theme = Theme.of(context);
    return OfflineOverlayDisplayer(
      child: OnlineStatusBuilder(
        builder: (context, online) {
          return BaseView<FeedScreenViewModel>(
            model: _viewModel,
            builder: (context, model, child) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Лента'),
                  forceMaterialTransparency: model.pinnedPosts.isNotEmpty,
                  actions: [
                    PopupMenuButton(
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            value: 'announcements',
                            child: Text('Важные сообщения'),
                          ),
                        ];
                      },
                      onSelected: (value) {
                        switch (value) {
                          case 'announcements':
                            GoRouter.of(context).go(
                              '${GoRouter.of(context).routeInformationProvider.value.uri.path}/'
                              '${announcementsRoute.pageRoute}',
                            );
                            break;
                        }
                      },
                    ),
                  ],
                  leading: parentScaffold?.hasDrawer ?? false
                      ? IconButton(
                          onPressed: () {
                            parentScaffold?.openDrawer();
                          },
                          icon: const Icon(Icons.menu),
                        )
                      : null,
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: NotificationListener<ScrollEndNotification>(
                        child: RefreshIndicator(
                          onRefresh: model.reload,
                          child: CustomScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              if (model.pinnedPosts.isNotEmpty)
                                SliverAppBar(
                                  primary: false,
                                  pinned: true,
                                  title: GestureDetector(
                                    onTap: () => openPinned(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      width: double.infinity,
                                      color: Theme.of(context).cardColor,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Закреплённые посты: ${model.pinnedPosts.length}',
                                              style: theme.textTheme.bodyLarge,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                openPinned(context),
                                            child: const Text(
                                              'Открыть',
                                              style: TextStyle(fontSize: 14.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (model.failedToLoad)
                                _coloredTopMessage(
                                  context,
                                  'Не удалось загрузить посты',
                                  const Color(0xFFBB1111),
                                  const Color(0xFFFFFFFF),
                                ),
                              if (!online && model.offlinePosts.isNotEmpty)
                                _coloredTopMessage(
                                  context,
                                  'Показаны последние загруженные посты',
                                  const Color(0xFF696969),
                                  const Color(0xFFFFFFFF),
                                ),
                              SliverToBoxAdapter(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: model.posts.length,
                                  itemBuilder: (context, index) {
                                    final post = model.posts[index];
                                    return FeedPost(
                                      key: ObjectKey(post),
                                      post: post,
                                      showingComments: false,
                                    );
                                  },
                                ),
                              ),
                              if (model.loadingMore &&
                                  online &&
                                  model.posts.isNotEmpty)
                                const SliverToBoxAdapter(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        onNotification: (scrollEnd) {
                          if (!online) return false;
                          final metrics = scrollEnd.metrics;

                          if (metrics.pixels >= metrics.maxScrollExtent - 300) {
                            model.loadMorePosts();
                          }

                          return true;
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
            onModelReady: (model) => model.init(),
          );
        },
      ),
    );
  }

  void openPinned(BuildContext context) {
    GoRouter.of(context).go(
      '${GoRouter.of(context).routeInformationProvider.value.uri.path}/'
      '${pinnedPostsRoute.pageRoute}',
    );
  }

  Widget _coloredTopMessage(
    BuildContext context,
    String text,
    Color background,
    Color foreground,
  ) {
    final theme = Theme.of(context);
    return PinnedHeaderSliver(
      child: Container(
        color: background,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 8.0,
        ),
        child: Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(color: foreground),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.scrollToTop = null;
    _viewModel.onRefresh = null;
    _scrollController.removeListener(scrollUpdate);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void refreshTab() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.decelerate,
    );
  }
}
