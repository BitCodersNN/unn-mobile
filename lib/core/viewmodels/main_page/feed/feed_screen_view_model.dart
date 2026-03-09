// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:unn_mobile/core/misc/authorisation/try_login_and_retrieve_data.dart';
import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/models/feed/blog_post_type.dart';
import 'package:unn_mobile/core/providers/interfaces/feed/blog_post_provider.dart';
import 'package:unn_mobile/core/providers/interfaces/feed/last_feed_load_date_time_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/stream_auth_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_receivers/refresh_blog_post_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/legacy/blog_post_receivers/featured_blog_post_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/legacy/blog_post_receivers/regular_blog_posts_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_post_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/main_page_route_view_model.dart';

class FeedScreenViewModel extends BaseViewModel
    implements MainPageRouteViewModel {
  static const postsPerPage = 20;
  final LastFeedLoadDateTimeProvider _lastFeedLoadDateTimeProvider;
  final BlogPostProvider _blogPostProvider;
  final RegularBlogPostsService _regularBlogPostsService;
  final FeaturedBlogPostsService _featuredBlogPostsService;

  // TEST
  final StreamAuthService _streamAuthService;
  final RefreshBlogPostService _blogPostServiceImpl;

  final List<FeedPostViewModel> offlinePosts = [];
  final List<FeedPostViewModel> pinnedPosts = [];
  final List<FeedPostViewModel> announcements = [];

  final List<FeedPostViewModel> _totalPosts = [];

  int _numberUnreadMessages = 0;
  int _currentPage = 0;
  bool _failedToLoad = false;

  List<FeedPostViewModel> get posts =>
      _totalPosts.take(postsPerPage * _currentPage).toList();

  int get numberUnreadMessages => _numberUnreadMessages;

  bool get failedToLoad => _failedToLoad;
  bool get loadingMore => _loadingMore;

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

  FeedScreenViewModel(
    this._lastFeedLoadDateTimeProvider,
    this._blogPostProvider,
    this._regularBlogPostsService,
    this._featuredBlogPostsService,

    // TEST
    this._streamAuthService,
    this._blogPostServiceImpl,
  );

  void init() {
    _blogPostProvider //
        .getData() //
        .then((posts) => _addPostsToList(offlinePosts, posts)) //
        .whenComplete(reload);
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
        if (loadingMore) {
          return;
        }
        loadingMore = true;
        final freshPosts = await tryLoginAndRetrieveData<List<BlogPost>?>(
          () => _regularBlogPostsService.getRegularBlogPosts(
            pageNumber: _currentPage + 1,
            postsPerPage: postsPerPage,
          ),
          () => null,
        );
        if (freshPosts == null) {
          failedToLoad = true;
          loadingMore = false;
          return;
        }
        _addPostsToList(_totalPosts, freshPosts);
        failedToLoad = false;
        _currentPage++;
        loadingMore = false;
      });

  Future<void> reload() async => await changeState(() async {
        failedToLoad = false;
        loadingMore = true;
        _numberUnreadMessages = 0;

        // TEST
        final posts = await _blogPostServiceImpl.refreshBlogPosts(
          assetsCheckSum: _streamAuthService.sonetLAssetsCheckSum ?? '',
          signedParameters: _streamAuthService.signedParameters ?? '',
          commentFormUID: _streamAuthService.commentFormUID ?? '',
        );

        final freshPosts = posts?[BlogPostType.regular];

        pinnedPosts.clear();
        _addPostsToList(
          pinnedPosts,
          posts?[BlogPostType.pinned],
          isRegularPost: false,
        );
        announcements.clear();
        _addPostsToList(
          announcements,
          posts?[BlogPostType.important],
          isRegularPost: false,
        );

        // final [_, _, freshPosts as List<BlogPost>?] = await Future.wait(
        //   [
        //     _lastFeedLoadDateTimeProvider.getData(),
        //     refreshFeatured(),
        //     tryLoginAndRetrieveData<List<BlogPost>>(
        //       () => _regularBlogPostsService.getRegularBlogPosts(
        //         postsPerPage: postsPerPage,
        //       ),
        //       () => null,
        //     ),
        //   ],
        // );

        if (freshPosts == null) {
          loadingMore = false;
          failedToLoad = true;
          return;
        }

        await Future.wait([
          _blogPostProvider.saveData(freshPosts),
          _lastFeedLoadDateTimeProvider
              .saveData(freshPosts.first.data.datePublish),
        ]);

        offlinePosts.clear();
        _totalPosts.clear();

        _addPostsToList(_totalPosts, freshPosts);

        offlinePosts.addAll(_totalPosts);
        loadingMore = false;
        _currentPage = 1;
      });

  Future<void> refreshFeatured() async => changeState(() async {
        final featuredPosts =
            await tryLoginAndRetrieveData<Map<BlogPostType, List<BlogPost>>>(
          _featuredBlogPostsService.getFeaturedBlogPosts,
          () => null,
        );
        pinnedPosts.clear();
        _addPostsToList(
          pinnedPosts,
          featuredPosts?[BlogPostType.pinned],
          isRegularPost: false,
        );
        announcements.clear();
        _addPostsToList(
          announcements,
          featuredPosts?[BlogPostType.important],
          isRegularPost: false,
        );
      });

  bool isPostPinned(int id) => pinnedPosts.any((p) => p.blogData.id == id);

  bool isPostImportant(int id) => announcements.any((p) => p.blogData.id == id);

  @override
  void refresh() {
    scrollToTop?.call();
  }
}
