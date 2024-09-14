import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/type_defs.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/online_status_data.dart';
import 'package:unn_mobile/core/services/interfaces/feed_updater_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_posts.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/post_with_loaded_info_provider.dart';

class FeedUpdaterServiceImpl with ChangeNotifier implements FeedUpdaterService {
  final LoggerService _loggerService;
  final PostWithLoadedInfoProvider _offlineFeedProvider;
  final LRUCacheLoadedBlogPost _lruCacheLoadedBlogPost;
  final OnlineStatusData _onlineStatusData;

  bool _busy = false;

  final List<BlogData> _postsList = [];

  int _lastLoadedPage = 0;

  final GettingBlogPosts _gettingBlogPostsService;

  FeedUpdaterServiceImpl(
    this._gettingBlogPostsService,
    this._loggerService,
    this._offlineFeedProvider,
    this._lruCacheLoadedBlogPost,
    this._onlineStatusData,
  ) {
    _onlineStatusData.notifier.addListener(onOnlineChanged);
    _loadOfflinePosts().then((_) {
      return loadNextPage();
    });
  }

  void onOnlineChanged() {
    if (_onlineStatusData.isOnline) {
      updateFeed();
    }
  }

  @override
  int get lastLoadedPage => _lastLoadedPage;

  Future<void> _loadOfflinePosts() async {
    if (_busy) {
      return;
    }
    _busy = true;
    try {
      final contained = await _offlineFeedProvider.isContained();
      if (contained) {
        _postsList.clear();
        _postsList.addAll(
          (await _offlineFeedProvider.getData())?.map(
                (e) {
                  _lruCacheLoadedBlogPost.save(e.post.id, e);
                  return e.post;
                },
              ) ??
              [],
        );
        notifyListeners();
      }
    } on Exception catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
    } finally {
      _busy = false;
    }
  }

  @override
  Future<void> loadNextPage() async {
    if (_busy) {
      return;
    }
    _busy = true;
    try {
      if (lastLoadedPage == 0) {
        _postsList.clear();
      }
      final posts = await _gettingBlogPostsService.getBlogPosts(
        pageNumber: _lastLoadedPage,
      );
      _postsList.addAll(posts ?? []);
      _lastLoadedPage++;
    } on Exception catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  @override
  List<BlogData> get feedPosts => _postsList;

  @override
  Future<void> updateFeed() async {
    _lastLoadedPage = 0;
    await loadNextPage();
  }

  @override
  void dispose() {
    _onlineStatusData.notifier.removeListener(onOnlineChanged);
    super.dispose();
  }
}
