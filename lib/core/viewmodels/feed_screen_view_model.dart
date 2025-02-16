import 'package:unn_mobile/core/services/interfaces/feed/blog_post_receivers/regular_blog_posts_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/providers/blog_post_provider.dart';
import 'package:unn_mobile/core/services/interfaces/feed/providers/last_feed_load_date_time_provider.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/feed_post_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page_route_view_model.dart';

class FeedScreenViewModel extends BaseViewModel
    implements MainPageRouteViewModel {
  static const postsPerPage = 10;
  late DateTime lastFeedLoadDateTime;
  final LastFeedLoadDateTimeProvider _lastFeedLoadDateTimeProvider;
  final BlogPostProvider _blogPostProvider;
  final RegularBlogPostsService _regularBlogPostsService;

  final List<FeedPostViewModel> posts = [];

  bool _failedToLoad = false;
  int _nextPage = 1;

  bool get failedToLoad => _failedToLoad;
  bool get showingOfflinePosts => _showingOfflinePosts;
  bool get loadingMore => _loadingMore;

  set failedToLoad(bool value) {
    _failedToLoad = value;
    notifyListeners();
  }

  set showingOfflinePosts(bool value) {
    _showingOfflinePosts = value;
    notifyListeners();
  }

  set loadingMore(bool value) {
    _loadingMore = value;
    notifyListeners();
  }

  double scrollPosition = 0.0;

  void Function()? scrollToTop;

  void Function()? onRefresh;

  bool _showingOfflinePosts = false;

  bool _loadingMore = false;

  FeedScreenViewModel(
    this._lastFeedLoadDateTimeProvider,
    this._blogPostProvider,
    this._regularBlogPostsService,
  );

  void init() {
    _lastFeedLoadDateTimeProvider.getData().then(
          (value) => lastFeedLoadDateTime = value ?? DateTime(2000, 1, 1),
        );
    showingOfflinePosts = true;
    _blogPostProvider
        .getData()
        .then(
          (value) => posts.addAll(
            value?.map(
                  (p) =>
                      FeedPostViewModel.cached(p.data.id)..initFromFullInfo(p),
                ) ??
                [],
          ),
        )
        .whenComplete(
      () async {
        await reload();
      },
    );
  }

  Future<void> loadMorePosts() async {
    if (loadingMore) {
      return;
    }
    loadingMore = true;
    final freshPosts = await _regularBlogPostsService.getRegularBlogPosts(
      pageNumber: _nextPage,
      postsPerPage: postsPerPage,
    );
    if (freshPosts == null) {
      failedToLoad = true;
      loadingMore = false;
      return;
    }
    posts.addAll(
      freshPosts.map(
        (p) => FeedPostViewModel.cached(p.data.id)..initFromFullInfo(p),
      ),
    );
    failedToLoad = false;
    _nextPage++;
    loadingMore = false;
  }

  Future<void> reload() async {
    failedToLoad = false;
    loadingMore = true;
    final freshPosts = await _regularBlogPostsService.getRegularBlogPosts(
      postsPerPage: postsPerPage,
    );
    if (freshPosts == null) {
      loadingMore = false;
      failedToLoad = true;
      return;
    }
    _blogPostProvider.saveData(freshPosts);
    posts.clear();
    notifyListeners();
    // Если не подождать, то не работает...
    await Future.delayed(const Duration(milliseconds: 500));
    posts.addAll(
      freshPosts.map(
        (p) => FeedPostViewModel.cached(p.data.id)..initFromFullInfo(p),
      ),
    );
    showingOfflinePosts = false;
    loadingMore = false;
    _nextPage = 2;
    notifyListeners();
  }

  @override
  void refresh() {
    scrollToTop?.call();
  }
}
