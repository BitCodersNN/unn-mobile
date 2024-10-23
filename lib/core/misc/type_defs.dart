import 'package:unn_mobile/core/misc/lru_cache.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/models/user_data.dart';

typedef LRUCacheUserData = LRUCache<int, UserData>;
typedef LRUCacheLoadedFile = LRUCache<int, FileData>;
typedef LRUCacheRatingList = LRUCache<int, RatingList>;
