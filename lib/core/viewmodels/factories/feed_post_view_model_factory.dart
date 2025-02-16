import 'package:unn_mobile/core/services/interfaces/feed/blog_post_receivers/blog_post_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/providers/last_feed_load_date_time_provider.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/factories/cached_view_model_factory_base.dart';
import 'package:unn_mobile/core/viewmodels/feed_post_view_model.dart';

typedef FeedPostCacheKey = int;

class FeedPostViewModelFactory
    extends CachedViewModelFactoryBase<FeedPostCacheKey, FeedPostViewModel> {
  FeedPostViewModelFactory() : super(100);

  @override
  FeedPostViewModel createViewModel(key) {
    return FeedPostViewModel(
      getService<BlogPostService>(),
      getService<LoggerService>(),
      getService<LastFeedLoadDateTimeProvider>(),
    );
  }
}
