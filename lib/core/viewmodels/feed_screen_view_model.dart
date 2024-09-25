import 'package:unn_mobile/core/services/interfaces/feed_updater_service.dart';
import 'package:unn_mobile/core/services/interfaces/last_feed_load_date_time_provider.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/feed_post_view_model.dart';

class FeedScreenViewModel extends BaseViewModel {
  final FeedUpdaterService _feedStreamUpdater;
  final LastFeedLoadDateTimeProvider _lastFeedLoadDateTimeProvider;

  bool _showUpdateButton = false;

  void Function()? scrollToTop;

  FeedScreenViewModel(
    this._feedStreamUpdater,
    this._lastFeedLoadDateTimeProvider,
  );

  final List<FeedPostViewModel> posts = [];

  bool _loadingPosts = false;

  bool get loadingPosts => _loadingPosts;

  int _lastLoadedPost = 0;

  bool get showSyncFeedButton => _showUpdateButton;
  set showSyncFeedButton(bool value) {
    _showUpdateButton = value;
    notifyListeners();
  }

  bool _isUpdatingFeed = false;

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

  void getMorePosts() {
    if (_isUpdatingFeed) {
      return;
    }
    if (_loadingPosts) {
      return;
    }
    _loadingPosts = true;
    notifyListeners();
    if (_lastLoadedPost + 5 > _feedStreamUpdater.feedPosts.length) {
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
            _lastLoadedPost + 5,
          )
          .map(
            (p) => FeedPostViewModel.cached(p.id)..init(p),
          ),
      //
    );
    _lastLoadedPost += 5;
    _loadingPosts = false;
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

  @override
  void dispose() {
    _feedStreamUpdater.removeListener(onFeedUpdated);
    super.dispose();
  }
}
