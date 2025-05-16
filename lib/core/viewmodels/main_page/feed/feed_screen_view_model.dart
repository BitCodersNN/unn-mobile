// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';
import 'package:unn_mobile/core/misc/authorisation/try_login_and_retrieve_data.dart';
import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/models/feed/blog_post_type.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_receivers/featured_blog_post_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_receivers/regular_blog_posts_service.dart';
import 'package:unn_mobile/core/providers/interfaces/feed/blog_post_provider.dart';
import 'package:unn_mobile/core/providers/interfaces/feed/last_feed_load_date_time_provider.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_post_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/main_page_route_view_model.dart';

class FeedScreenViewModel extends BaseViewModel
    implements MainPageRouteViewModel {
  static const postsPerPage = 10;
  late DateTime lastFeedLoadDateTime;
  final LastFeedLoadDateTimeProvider _lastFeedLoadDateTimeProvider;
  final BlogPostProvider _blogPostProvider;
  final RegularBlogPostsService _regularBlogPostsService;
  final FeaturedBlogPostsService _featuredBlogPostsService;

  final List<FeedPostViewModel> posts = [];
  final List<FeedPostViewModel> offlinePosts = [];
  final List<FeedPostViewModel> pinnedPosts = [];
  final List<FeedPostViewModel> announcements = [];

  bool _failedToLoad = false;
  int _nextPage = 1;

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
  );

  void init() {
    _lastFeedLoadDateTimeProvider.getData().then(
          (value) => lastFeedLoadDateTime = value ?? DateTime(2000, 1, 1),
        );
    _blogPostProvider //
        .getData() //
        .then((posts) => _addPostsToList(offlinePosts, posts)) //
        .whenComplete(reload);
  }

  void _addPostsToList(
    List<FeedPostViewModel> posts,
    List<BlogPost>? newPosts,
  ) {
    final postViewmodels = newPosts?.map(
      (p) {
        final post = FeedPostViewModel.cached(p.data.id);
        post.initFromFullInfo(p, this);
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
          () async => await _regularBlogPostsService.getRegularBlogPosts(
            pageNumber: _nextPage,
            postsPerPage: postsPerPage,
          ),
          () => null,
        );
        if (freshPosts == null) {
          failedToLoad = true;
          loadingMore = false;
          return;
        }
        _addPostsToList(posts, freshPosts);
        failedToLoad = false;
        _nextPage++;
        loadingMore = false;
      });

  Future<void> reload() async => await changeState(() async {
        failedToLoad = false;
        loadingMore = true;

        await refreshFeatured();

        final freshPosts = await tryLoginAndRetrieveData(
          () async => await _regularBlogPostsService.getRegularBlogPosts(
            postsPerPage: postsPerPage,
          ),
          () => null,
        );
        if (freshPosts == null) {
          loadingMore = false;
          failedToLoad = true;
          return;
        }
        _blogPostProvider.saveData(freshPosts);
        offlinePosts.clear();
        posts.clear();

        _addPostsToList(posts, freshPosts);

        offlinePosts.addAll(posts);
        loadingMore = false;
        _nextPage = 2;
      });

  Future<void> refreshFeatured() async => changeState(() async {
        final featuredPosts = await tryLoginAndRetrieveData(
          () async => await _featuredBlogPostsService.getFeaturedBlogPosts(),
          () => null,
        );
        pinnedPosts.clear();
        _addPostsToList(pinnedPosts, featuredPosts?[BlogPostType.pinned]);
        announcements.clear();
        _addPostsToList(announcements, featuredPosts?[BlogPostType.important]);
      });

  bool isPostPinned(int id) => pinnedPosts.any((p) => p.blogData.id == id);

  bool isPostImportant(int id) => announcements.any((p) => p.blogData.id == id);

  @override
  void refresh() {
    scrollToTop?.call();
  }
}
