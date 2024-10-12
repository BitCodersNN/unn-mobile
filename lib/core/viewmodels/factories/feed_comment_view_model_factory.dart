part of 'library.dart';

typedef FeedCommentCacheKey = int;

class FeedCommentViewModelFactory extends CachedViewModelFactoryBase<
    FeedCommentCacheKey, FeedCommentViewModel> {
  FeedCommentViewModelFactory() : super(100);

  @override
  FeedCommentViewModel createViewModel(key) {
    return FeedCommentViewModel();
  }
}
