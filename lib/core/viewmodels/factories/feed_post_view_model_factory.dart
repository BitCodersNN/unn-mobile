part of 'library.dart';

typedef FeedPostCacheKey = int;

class FeedPostViewModelFactory
    extends CachedViewModelFactoryBase<FeedPostCacheKey, FeedPostViewModel> {
  FeedPostViewModelFactory() : super(100);

  @override
  FeedPostViewModel createViewModel(key) {
    return FeedPostViewModel(
      getService<GettingBlogPosts>(),
      getService<LoggerService>(),
      getService<LastFeedLoadDateTimeProvider>(),
    );
  }
}
