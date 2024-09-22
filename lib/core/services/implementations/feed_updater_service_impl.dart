import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/online_status_data.dart';
import 'package:unn_mobile/core/services/interfaces/feed_updater_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_posts.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class FeedUpdaterServiceImpl with ChangeNotifier implements FeedUpdaterService {
  final LoggerService _loggerService;
  final OnlineStatusData _onlineStatusData;

  bool _busy = false;

  final List<BlogData> _postsList = [];

  int _lastLoadedPage = 0;

  final GettingBlogPosts _gettingBlogPostsService;

  FeedUpdaterServiceImpl(
    this._gettingBlogPostsService,
    this._loggerService,
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
    // TODO: сделать офлайн загрузку постов
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
