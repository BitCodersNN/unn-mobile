import 'package:unn_mobile/core/services/interfaces/feed_updater_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/feed_post_view_model.dart';

class FeedScreenViewModel extends BaseViewModel {
  final FeedUpdaterService _feedStreamUpdater;

  bool _showUpdateButton = false;

  void Function()? scrollToTop;

  FeedScreenViewModel(
    this._feedStreamUpdater,
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
    if (_loadingPosts) return;
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
      loadNextPage();
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
    Future.delayed(const Duration(milliseconds: 300), () {
      getMorePosts();
      scrollToTop?.call();
    });
  }

  /// Отправляет сигнал сервису для обновления постов
  Future<void> updateFeed() async {
    showSyncFeedButton = false;
    await _feedStreamUpdater.updateFeed();
    syncFeed();
  }

  void loadNextPage() {
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
