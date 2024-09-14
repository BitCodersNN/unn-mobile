import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';

abstract interface class FeedPostDataLoader {
  Future<PostWithLoadedInfo> load(BlogData data);
}
