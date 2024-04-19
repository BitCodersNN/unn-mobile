import 'package:unn_mobile/core/misc/lru_cache.dart';
import 'package:unn_mobile/core/models/blog_post_comment_with_loaded_info.dart';
import 'package:unn_mobile/core/models/user_data.dart';

typedef LRUCacheBlogPostCommentWithLoadedInfo = LRUCache<int, BlogPostCommentWithLoadedInfo>;
typedef LRUCacheUserData = LRUCache<int, UserData>;
