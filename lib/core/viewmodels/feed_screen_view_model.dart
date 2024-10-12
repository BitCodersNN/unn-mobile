part of 'package:unn_mobile/core/viewmodels/library.dart';

class FeedScreenViewModel extends BaseViewModel {
  static const postsPerPage = 5;

  final FeedUpdaterService _feedStreamUpdater;
  final LastFeedLoadDateTimeProvider _lastFeedLoadDateTimeProvider;

  final List<FeedPostViewModel> posts = [];

  bool _showUpdateButton = false;

  void Function()? scrollToTop;

  bool _loadingPosts = false;

  int _lastLoadedPost = 0;

  bool _isUpdatingFeed = false;

  FeedScreenViewModel(
    this._feedStreamUpdater,
    this._lastFeedLoadDateTimeProvider,
  );

  bool get loadingPosts => _loadingPosts;

  bool get showSyncFeedButton => _showUpdateButton;

  set showSyncFeedButton(bool value) {
    _showUpdateButton = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _feedStreamUpdater.removeListener(onFeedUpdated);
    super.dispose();
  }

  void getMorePosts() {
    if (_isUpdatingFeed) {
      return;
    }
    if (_loadingPosts) {
      return;
    }
    _loadingPosts = true;
    notifyListeners();

    if (_lastLoadedPost + postsPerPage > _feedStreamUpdater.feedPosts.length) {
      posts.addAll(
        _feedStreamUpdater.feedPosts
            .getRange(
              _lastLoadedPost,
              _feedStreamUpdater.feedPosts.length,
            )
            .map(
              (p) => FeedPostViewModel.cached(p.id)..init(p),
            ),
        //
      );
      _lastLoadedPost = _feedStreamUpdater.feedPosts.length;
      notifyListeners();
      _loadNextPage();
      return;
    }
    posts.addAll(
      _feedStreamUpdater.feedPosts
          .getRange(
            _lastLoadedPost,
            _lastLoadedPost + postsPerPage,
          )
          .map(
            (p) => FeedPostViewModel.cached(p.id)..init(p),
          ),
      //
    );
    _lastLoadedPost += postsPerPage;
    _loadingPosts = false;
    notifyListeners();
  }

  void init({void Function()? scrollToTop}) {
    this.scrollToTop = scrollToTop;
    syncFeed();
    _feedStreamUpdater.addListener(onFeedUpdated);
  }

  void onFeedUpdated() {
    if (posts.isEmpty) {
      syncFeed();
      return;
    }
    if (_feedStreamUpdater.feedPosts.firstOrNull !=
        posts.firstOrNull?.blogData) {
      showSyncFeedButton = true;
    }
    notifyListeners();
  }

  /// Синхронизирует посты в вьюмодели с сервисом
  void syncFeed() {
    _lastLoadedPost = 0;
    posts.clear();
    showSyncFeedButton = false;
    Future.delayed(const Duration(milliseconds: 300), () async {
      getMorePosts();
      scrollToTop?.call();
      // await _lastFeedLoadDateTimeProvider.saveData(DateTime.now());
      Future.delayed(const Duration(seconds: 2), () async {
        if (posts.isNotEmpty) {
          _lastFeedLoadDateTimeProvider.saveData(posts.first.postTime);
        }
      });
    });
  }

  /// Отправляет сигнал сервису для обновления постов
  Future<void> updateFeed() async {
    showSyncFeedButton = false;
    _isUpdatingFeed = true;
    await _feedStreamUpdater.updateFeed();
    _isUpdatingFeed = false;
    syncFeed();
  }

  void _loadNextPage() {
    _loadingPosts = true;
    _feedStreamUpdater.loadNextPage().whenComplete(() {
      _loadingPosts = false;
      notifyListeners();
    });
  }
}
