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
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_post_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/main_page_route_view_model.dart';

class FeedScreenViewModel extends BaseViewModel
    implements MainPageRouteViewModel {
  static const postsPerPage = 20;
  final LastFeedLoadDateTimeProvider _lastFeedLoadDateTimeProvider;
  final BlogPostProvider _blogPostProvider;
  final BlogPostPaginationService _postPaginationService;

  final StreamAuthService _streamAuthService;
  final RefreshBlogPostService _blogPostServiceImpl;

  final BlogPostSearchService _searchService;

  final List<FeedPostViewModel> offlinePosts = [];
  final List<FeedPostViewModel> pinnedPosts = [];

  final List<FeedPostViewModel> _totalPosts = [];

  int _numberUnreadMessages = 0;
  int _currentPage = 0;
  bool _failedToLoad = false;
  String? _searchQuery;
  DateTime? _lastReadAt;
  bool _isReplacingPosts = false;

  DateTime? get lastReadAt => _lastReadAt;

  List<FeedPostViewModel> get posts =>
      _totalPosts.take(postsPerPage * _currentPage).toList();

  int get numberUnreadMessages => _numberUnreadMessages;

  bool get failedToLoad => _failedToLoad;
  bool get loadingMore => _loadingMore;
  bool get isReplacingPosts => _isReplacingPosts;

  String? get searchQuery => _searchQuery;
  bool get hasSearch => _searchQuery != null;
  bool get showOnlyImportant => _filter == FeedFilter.important;
  FeedFilter get filter => _filter;

  set failedToLoad(bool value) {
    _failedToLoad = value;
    notifyListeners();
  }

  set loadingMore(bool value) {
    _loadingMore = value;
    notifyListeners();
  }

  double scrollPosition = 0.0;

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

  Future<void> init() async {
    _lastReadAt = await _lastFeedLoadDateTimeProvider.getData();
    offlinePosts.clear();
    final cachedPosts = await _blogPostProvider.getData();
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
          _numberUnreadMessages++;
        }
        return post;
      },
    );
    posts.addAll(postViewmodels ?? []);
  }

  Future<void> loadMorePosts() async => await changeState(() async {
        if (loadingMore || _currentPage <= 0) {
          return;
        }
        loadingMore = true;
        final freshPosts =
            await tryLoginAndRetrieveData<Map<BlogPostType, List<BlogPost>>>(
          () => _postPaginationService.loadNextPageBlogPosts(
            pageNumber: _currentPage + 1,
            pinIds: _totalPosts
                .skip(postsPerPage * (_currentPage - 1))
                .map((t) => t.blogData?.pinnedId)
                .nonNulls
                .toSet(),
            signedParameters: _streamAuthService.signedParameters ?? '',
            commentFormUID: _streamAuthService.commentFormUID ?? '',
            blogCommentFormUID: _streamAuthService.blogCommentFormUID ?? '',
          ),
          () => null,
        );

        if (freshPosts == null) {
          failedToLoad = true;
          loadingMore = false;
          return;
        }
        _addPostsToList(_totalPosts, freshPosts[BlogPostType.regular]);

        failedToLoad = false;
        _currentPage++;
        loadingMore = false;
      });

  Future<void> reload({bool updateMainPage = true}) async =>
      await changeState(() async {
        if (updateMainPage) {
          failedToLoad = false;
          loadingMore = true;
          _numberUnreadMessages = 0;
        }

        final posts = await tryLoginAndRetrieveData(
          () => _blogPostServiceImpl.refreshBlogPosts(
            assetsCheckSum: _streamAuthService.sonetLAssetsCheckSum ?? '',
            signedParameters: _streamAuthService.signedParameters ?? '',
            commentFormUID: _streamAuthService.commentFormUID ?? '',
          ),
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
        _currentPage = 1;
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
        if (value.trim().isEmpty) {
          return;
        }

        await _applySelection(filter: _filter, query: value.trim());
      });

  FutureOr<void> resetSearch() async => await busyCallAsync(() async {
        await _applySelection(filter: _filter, query: null);
      });

  FutureOr<void> setFilter(FeedFilter value) async =>
      await busyCallAsync(() async {
        if (value == _filter) {
          return;
        }
        final onlyImportant = value == FeedFilter.important;
        if (onlyImportant == showOnlyImportant) {
          _filter = value;
          notifyListeners();
          return;
        }
        await _applySelection(filter: value, query: _searchQuery);
      });

  Future<void> _applySelection({
    required FeedFilter filter,
    required String? query,
  }) async {
    _isReplacingPosts = true;
    notifyListeners();
    try {
      final applied = await _searchService.setFilter(
        onlyImportant: filter == FeedFilter.important,
        query: query ?? '',
      );
      if (applied) {
        _filter = filter;
        _searchQuery = query;
        _totalPosts.clear();
        offlinePosts.clear();
        _currentPage = 0;
        await reload();
      }
    } finally {
      _isReplacingPosts = false;
      notifyListeners();
    }
  }
}
