import 'package:unn_mobile/core/viewmodels/factories/cached_view_model_factory_base.dart';
import 'package:unn_mobile/core/viewmodels/feed_comment_view_model.dart';

typedef FeedCommentCacheKey = int;

class FeedCommentViewModelFactory extends CachedViewModelFactoryBase<
    FeedCommentCacheKey, FeedCommentViewModel> {
  FeedCommentViewModelFactory() : super(100);

  @override
  FeedCommentViewModel createViewModel(key) {
    return FeedCommentViewModel();
  }
}
