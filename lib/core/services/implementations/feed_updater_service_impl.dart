part of 'library.dart';

class FeedUpdaterServiceImpl with ChangeNotifier implements FeedUpdaterService {
  final LoggerService _loggerService;
  final OnlineStatusData _onlineStatusData;
  final AuthorizationService _authorizationService;
  final LastFeedLoadDateTimeProvider _lastLoadDateProvider;
  final GettingBlogPosts _gettingBlogPostsService;

  bool _busy = false;

  final List<BlogData> _postsList = [];

  int _lastLoadedPage = 0;

  FeedUpdaterServiceImpl(
    this._gettingBlogPostsService,
    this._loggerService,
    this._onlineStatusData,
    this._lastLoadDateProvider,
    this._authorizationService,
  ) {
    _onlineStatusData.notifier.addListener(onOnlineChanged);
    _authorizationService.addListener(onAuthChanged);
    _loadOfflinePosts().then((_) async {
      await _lastLoadDateProvider
          .getData(); // Вытягиваем сохранённую дату заранее
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

  void onAuthChanged() {
    if (!_authorizationService.isAuthorised) {
      clearPosts();
    }
  }

  void clearPosts() {
    _postsList.clear();
    _lastLoadedPage = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _onlineStatusData.notifier.removeListener(onOnlineChanged);
    _authorizationService.removeListener(onAuthChanged);
    super.dispose();
  }
}
