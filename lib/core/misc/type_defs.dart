import 'package:unn_mobile/core/misc/lru_cache.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/models/loaded_blog_post_comment.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/models/user_data.dart';

typedef LRUCacheLoadedBlogPostComment = LRUCache<int, LoadedBlogPostComment>;
typedef LRUCacheUserData = LRUCache<int, UserData>;
typedef LRUCacheLoadedBlogPost = LRUCache<int, PostWithLoadedInfo>;
typedef LRUCacheLoadedFile = LRUCache<int, FileData>;
typedef LRUCacheRatingList = LRUCache<int, RatingList>;
