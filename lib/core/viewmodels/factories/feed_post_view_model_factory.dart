import 'package:unn_mobile/core/services/interfaces/feed/blog_post_receivers/blog_post_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/featured_blog_post_action/important_blog_post_acknowledgement_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/featured_blog_post_action/pinning_blog_post_service.dart';
import 'package:unn_mobile/core/providers/interfaces/feed/last_feed_load_date_time_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
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
      getService<ImportantBlogPostAcknowledgementService>(),
      getService<PinningBlogPostService>(),
    );
  }
}
