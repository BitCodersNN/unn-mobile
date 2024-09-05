import 'package:unn_mobile/core/misc/lru_cache.dart';
import 'package:unn_mobile/core/models/loaded_blog_post_comment.dart';
import 'package:unn_mobile/core/models/user_data.dart';

typedef LRUCacheLoadedBlogPostComment = LRUCache<int, LoadedBlogPostComment>;
typedef LRUCacheUserData = LRUCache<int, UserData>;
