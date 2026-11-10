// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:unn_mobile/core/misc/authorisation/try_login_and_retrieve_data.dart';
import 'package:unn_mobile/core/misc/html_utils/html_to_plain_text.dart';
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
  final LastFeedLoadDateTimeProvider _lastFeedLoadDateTimeProvider;
  final BlogPostProvider _blogPostProvider;
  final BlogPostPaginationService _postPaginationService;

  final StreamAuthService _streamAuthService;
  final RefreshBlogPostService _blogPostServiceImpl;

  final BlogPostSearchService _searchService;

  final Map<_FeedSelection, FeedPageState> _pages = {};
  final Map<FeedFilter, double> _scrollPositions = {};
  _FeedSelection? _serverSelection;

  _FeedSelection get _selection =>
      (onlyImportant: showOnlyImportant, query: _searchQuery);

  FeedPageState get _page => _pages.putIfAbsent(_selection, FeedPageState.new);

  List<FeedPostViewModel> get pinnedPosts => _page.pinnedPosts;

  List<FeedPostViewModel> get _totalPosts => _page.posts;

  Future<void>? _initialization;

  String? _searchQuery;
  DateTime? _lastReadAt;
  int? _pinnedPostCount;
  bool _isReplacingPosts = false;

  DateTime? get lastReadAt => _lastReadAt;

  List<FeedPostViewModel> get posts => List.of(_totalPosts);

  List<FeedPostViewModel> get visiblePosts => switch (_filter) {
    FeedFilter.all => posts,
    FeedFilter.pinned => _matchingPinnedPosts,
    FeedFilter.important => _importantPosts(posts, _matchingPinnedPosts),
  };

  List<FeedPostViewModel> get _matchingPinnedPosts {
    final query = searchQuery?.toLowerCase();
    if (query == null) {
      return pinnedPosts;
    }
    return pinnedPosts
        .where(
          (post) =>
              htmlToPlainText(post.postText).toLowerCase().contains(query) ||
              (post.profileViewModel?.fullname.toLowerCase().contains(query) ??
                  false),
        )
        .toList();
  }

  List<FeedPostViewModel> _importantPosts(
    List<FeedPostViewModel> regular,
    List<FeedPostViewModel> pinned,
  ) {
    final postsById = <int, FeedPostViewModel>{};
    for (final post in [...regular, ...pinned]) {
      final id = post.blogData?.id;
      if (id != null && post.isAnnouncement) {
        postsById[id] = post;
      }
    }
    return postsById.values.toList()..sort((first, second) {
      final dateOrder = (second.postTime?.millisecondsSinceEpoch ?? 0)
          .compareTo(first.postTime?.millisecondsSinceEpoch ?? 0);
      return dateOrder != 0
          ? dateOrder
          : second.blogData!.id.compareTo(first.blogData!.id);
    });
  }

  Map<FeedFilter, int> get unreadCounts {
    final all = _pages[(onlyImportant: false, query: null)];
    final important = _pages[(onlyImportant: true, query: null)];
    return {
      if (all != null)
        FeedFilter.all: all.posts.where((post) => post.isNewPost).length,
      if (important != null && important.isLoaded)
        FeedFilter.important: _importantPosts(
          important.posts,
          important.pinnedPosts,
        ).where((post) => post.isNewPost).length,
    };
  }

  int? get pinnedPostCount => _pinnedPostCount;

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

  Future<void> _initialize() async => await busyCallAsync(_loadInitialPosts);

  Future<void> _loadInitialPosts() async {
    final lastReadAt = await _lastFeedLoadDateTimeProvider.getData();
    final cachedPosts = await _blogPostProvider.getData();
    if (disposed) {
      return;
    }
    _lastReadAt = lastReadAt;
    _totalPosts.clear();
    _addPostsToList(_totalPosts, cachedPosts);
    notifyListeners();
    await reload();
  }

  void _addPostsToList(
    List<FeedPostViewModel> posts,
    List<BlogPost>? newPosts,
  ) {
    final ids = posts.map((post) => post.blogData?.id).nonNulls.toSet();
    for (final post in newPosts ?? <BlogPost>[]) {
      final model = FeedPostViewModel.cached(post.data.id)
        ..initFromFullInfo(post, this);
      if (ids.add(post.data.id)) {
        posts.add(model);
      }
    }
  }

  void _updatePinnedPosts(List<BlogPost>? posts, {bool replace = true}) {
    if (replace) {
      pinnedPosts.clear();
    }
    _addPostsToList(pinnedPosts, posts);
    if (!hasSearch && !showOnlyImportant) {
      _pinnedPostCount = pinnedPosts.length;
    }
  }

  Set<int> _pagePinIds(Map<BlogPostType, List<BlogPost>> posts) =>
      (posts[BlogPostType.regular] ?? [])
          .map((post) => post.data.pinnedId)
          .nonNulls
          .toSet();

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
              pinIds: _page.lastPagePinIds,
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
    _updatePinnedPosts(freshPosts[BlogPostType.pinned], replace: false);
    _page.lastPagePinIds = _pagePinIds(freshPosts);

    failedToLoad = false;
    _page.pageNumber++;
    loadingMore = false;
  });

  Future<void> reload({
    bool updateMainPage = true,
    bool markLoadedPostsRead = false,
  }) async => await changeState(() async {
    final readThrough = markLoadedPostsRead ? _latestLoadedPostTime() : null;
    if (updateMainPage) {
      failedToLoad = false;
      loadingMore = true;
    }

    final posts = await tryLoginAndRetrieveData(() async {
      if (!await _ensureServerSelection(_selection)) {
        return null;
      }
      return _blogPostServiceImpl.refreshBlogPosts(
        assetsCheckSum: _streamAuthService.sonetLAssetsCheckSum ?? '',
        signedParameters: _streamAuthService.signedParameters ?? '',
        commentFormUID: _streamAuthService.commentFormUID ?? '',
      );
    }, () => null);

    if (posts == null) {
      if (updateMainPage) {
        failedToLoad = true;
        loadingMore = false;
      }
      return;
    }

    if (readThrough != null) {
      await _lastFeedLoadDateTimeProvider.saveData(readThrough);
      _lastReadAt = readThrough;
    }

    _updatePinnedPosts(posts[BlogPostType.pinned]);

    if (!updateMainPage) {
      if (showOnlyImportant) {
        _addPostsToList(_totalPosts, posts[BlogPostType.regular]);
      }
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
        _lastFeedLoadDateTimeProvider.saveData(
          _laterDate(freshPosts.first.data.datePublish, _lastReadAt),
        ),
      ]);
    }

    _totalPosts.clear();

    _addPostsToList(_totalPosts, freshPosts);

    loadingMore = false;
    _page.pageNumber = 1;
    _page.lastPagePinIds = _pagePinIds(posts);
    _page.isLoaded = true;
  });

  DateTime? _latestLoadedPostTime() {
    DateTime? latest = _lastReadAt;
    for (final page in _pages.values) {
      for (final post in [...page.posts, ...page.pinnedPosts]) {
        final date = post.postTime;
        if (date != null) {
          latest = _laterDate(date, latest);
        }
      }
    }
    return latest;
  }

  DateTime _laterDate(DateTime date, DateTime? previous) =>
      previous != null && previous.isAfter(date) ? previous : date;

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
      final applied = await _ensureServerSelection((
        onlyImportant: filter == FeedFilter.important,
        query: query,
      ));
      if (applied) {
        if (query != _searchQuery) {
          _pages.clear();
          _scrollPositions.clear();
        }
        _filter = filter;
        _searchQuery = query;
        _totalPosts.clear();
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
