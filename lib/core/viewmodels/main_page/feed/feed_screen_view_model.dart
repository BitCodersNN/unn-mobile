// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:unn_mobile/core/misc/authorisation/try_login_and_retrieve_data.dart';
import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/models/feed/blog_post_type.dart';
import 'package:unn_mobile/core/models/feed/feed_filter.dart';
import 'package:unn_mobile/core/providers/interfaces/feed/blog_post_provider.dart';
import 'package:unn_mobile/core/providers/interfaces/feed/last_feed_load_date_time_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/stream_auth_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_receivers/blog_post_pagination_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_receivers/refresh_blog_post_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_search_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_page_state.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_post_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/main_page_route_view_model.dart';

typedef _FeedSelection = ({bool onlyImportant, String? query});

class FeedScreenViewModel extends BaseViewModel
    implements MainPageRouteViewModel {
  static const postsPerPage = 20;
  final LastFeedLoadDateTimeProvider _lastFeedLoadDateTimeProvider;
  final BlogPostProvider _blogPostProvider;
  final BlogPostPaginationService _postPaginationService;

  final StreamAuthService _streamAuthService;
  final RefreshBlogPostService _blogPostServiceImpl;

  final BlogPostSearchService _searchService;

  final Map<_FeedSelection, FeedPageState> _pages = {};
  final Map<FeedFilter, double> _scrollPositions = {};
  _FeedSelection? _serverSelection;

  _FeedSelection get _selection => (
        onlyImportant: showOnlyImportant,
        query: _searchQuery,
      );

  FeedPageState get _page => _pages.putIfAbsent(_selection, FeedPageState.new);

  List<FeedPostViewModel> get offlinePosts => _page.offlinePosts;
  List<FeedPostViewModel> get pinnedPosts => _page.pinnedPosts;

  List<FeedPostViewModel> get _totalPosts => _page.posts;

  Future<void>? _initialization;

  String? _searchQuery;
  DateTime? _lastReadAt;
  bool _isReplacingPosts = false;

  DateTime? get lastReadAt => _lastReadAt;

  List<FeedPostViewModel> get posts =>
      _totalPosts.take(postsPerPage * _page.pageNumber).toList();

  int get numberUnreadMessages => _page.unreadCount;

  bool get failedToLoad => _page.failedToLoad;
  bool get loadingMore => _loadingMore;
  bool get isReplacingPosts => _isReplacingPosts;

  String? get searchQuery => _searchQuery;
  bool get hasSearch => _searchQuery != null;
  bool get showOnlyImportant => _filter == FeedFilter.important;
  FeedFilter get filter => _filter;

  set failedToLoad(bool value) {
    _page.failedToLoad = value;
    notifyListeners();
  }

  set loadingMore(bool value) {
    _loadingMore = value;
    notifyListeners();
  }

  double get scrollPosition => _scrollPositions[_filter] ?? 0;

  set scrollPosition(double value) => _scrollPositions[_filter] = value;

  void Function()? scrollToTop;

  void Function()? onRefresh;

  bool _loadingMore = false;

  FeedFilter _filter = FeedFilter.all;

  FeedScreenViewModel(
    this._lastFeedLoadDateTimeProvider,
    this._blogPostProvider,
    this._streamAuthService,
    this._blogPostServiceImpl,
    this._postPaginationService,
    this._searchService,
  );

  Future<void> init() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    final lastReadAt = await _lastFeedLoadDateTimeProvider.getData();
    final cachedPosts = await _blogPostProvider.getData();
    if (disposed) {
      return;
    }
    _lastReadAt = lastReadAt;
    offlinePosts.clear();
    _addPostsToList(offlinePosts, cachedPosts);
    notifyListeners();
    await reload();
  }

  void _addPostsToList(
    List<FeedPostViewModel> posts,
    List<BlogPost>? newPosts, {
    bool isRegularPost = true,
  }) {
    final postViewmodels = newPosts?.map(
      (p) {
        final post = FeedPostViewModel.cached(p.data.id)
          ..initFromFullInfo(p, this);
        if (post.isNewPost && isRegularPost) {
          _page.unreadCount++;
        }
        return post;
      },
    );
    posts.addAll(postViewmodels ?? []);
  }

  Future<void> loadMorePosts() async => await changeState(() async {
        if (loadingMore || isBusy || _page.pageNumber <= 0) {
          return;
        }
        loadingMore = true;
        final freshPosts =
            await tryLoginAndRetrieveData<Map<BlogPostType, List<BlogPost>>>(
          () async {
            if (!await _ensureServerSelection(_selection)) {
              return null;
            }
            return _postPaginationService.loadNextPageBlogPosts(
              pageNumber: _page.pageNumber + 1,
              pinIds: _totalPosts
                  .skip(postsPerPage * (_page.pageNumber - 1))
                  .map((t) => t.blogData?.pinnedId)
                  .nonNulls
                  .toSet(),
              signedParameters: _streamAuthService.signedParameters ?? '',
              commentFormUID: _streamAuthService.commentFormUID ?? '',
              blogCommentFormUID: _streamAuthService.blogCommentFormUID ?? '',
            );
          },
          () => null,
        );

        if (freshPosts == null) {
          failedToLoad = true;
          loadingMore = false;
          return;
        }
        _addPostsToList(_totalPosts, freshPosts[BlogPostType.regular]);

        failedToLoad = false;
        _page.pageNumber++;
        loadingMore = false;
      });

  Future<void> reload({bool updateMainPage = true}) async =>
      await changeState(() async {
        if (updateMainPage) {
          failedToLoad = false;
          loadingMore = true;
          _page.unreadCount = 0;
        }

        final posts = await tryLoginAndRetrieveData(
          () async {
            if (!await _ensureServerSelection(_selection)) {
              return null;
            }
            return _blogPostServiceImpl.refreshBlogPosts(
              assetsCheckSum: _streamAuthService.sonetLAssetsCheckSum ?? '',
              signedParameters: _streamAuthService.signedParameters ?? '',
              commentFormUID: _streamAuthService.commentFormUID ?? '',
            );
          },
          () => null,
        );

        if (posts == null) {
          if (updateMainPage) {
            failedToLoad = true;
            loadingMore = false;
          }
          return;
        }

        pinnedPosts.clear();
        _addPostsToList(
          pinnedPosts,
          posts[BlogPostType.pinned],
          isRegularPost: false,
        );

        if (!updateMainPage) {
          for (final entry in _pages.entries) {
            if (entry.key != _selection) {
              entry.value.isLoaded = false;
            }
          }
          return;
        }

        final freshPosts = posts[BlogPostType.regular] ?? [];

        if (!hasSearch && !showOnlyImportant && freshPosts.isNotEmpty) {
          await Future.wait([
            _blogPostProvider.saveData(freshPosts),
            _lastFeedLoadDateTimeProvider
                .saveData(freshPosts.first.data.datePublish),
          ]);
        }

        offlinePosts.clear();
        _totalPosts.clear();

        _addPostsToList(_totalPosts, freshPosts);

        offlinePosts.addAll(_totalPosts);
        loadingMore = false;
        _page.pageNumber = 1;
        _page.isLoaded = true;
      });

  Future<void> refreshFeatured() => reload(updateMainPage: false);
  bool isPostPinned(int? id) =>
      id != null && pinnedPosts.any((p) => p.blogData?.id == id);

  @override
  void refresh() {
    scrollToTop?.call();
  }

  FutureOr<void> submitSearch(String value) async =>
      await busyCallAsync(() async {
        if (value.trim().isEmpty || loadingMore) {
          return;
        }

        await _applySelection(filter: _filter, query: value.trim());
      });

  FutureOr<void> resetSearch() async => await busyCallAsync(() async {
        if (loadingMore) {
          return;
        }
        await _applySelection(filter: _filter, query: null);
      });

  FutureOr<void> setFilter(FeedFilter value) async =>
      await busyCallAsync(() async {
        if (value == _filter || loadingMore) {
          return;
        }
        final onlyImportant = value == FeedFilter.important;
        final selection = (onlyImportant: onlyImportant, query: _searchQuery);
        if (onlyImportant == showOnlyImportant ||
            (_pages[selection]?.isLoaded ?? false)) {
          _filter = value;
          notifyListeners();
          return;
        }
        await _applySelection(filter: value, query: _searchQuery);
      });

  Future<bool> _ensureServerSelection(_FeedSelection selection) async {
    if (_serverSelection == selection) {
      return true;
    }
    final applied = await _searchService.setFilter(
      onlyImportant: selection.onlyImportant,
      query: selection.query ?? '',
    );
    if (applied) {
      _serverSelection = selection;
    }
    return applied;
  }

  Future<void> _applySelection({
    required FeedFilter filter,
    required String? query,
  }) async {
    _isReplacingPosts = true;
    notifyListeners();
    try {
      final applied = await _ensureServerSelection(
        (
          onlyImportant: filter == FeedFilter.important,
          query: query,
        ),
      );
      if (applied) {
        if (query != _searchQuery) {
          _pages.clear();
          _scrollPositions.clear();
        }
        _filter = filter;
        _searchQuery = query;
        _totalPosts.clear();
        offlinePosts.clear();
        _page.pageNumber = 0;
        _page.isLoaded = false;
        await reload();
      }
    } finally {
      _isReplacingPosts = false;
      notifyListeners();
    }
  }
}
