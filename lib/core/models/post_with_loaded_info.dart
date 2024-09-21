import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/rating_list.dart';

class KeysForPostWithLoadedInfoJsonConverter {
  static const String author = 'author';
  static const String post = 'post';
  static const String files = 'files';
  static const String ratingList = 'ratingList';
}

class PostWithLoadedInfo {
  final BlogData _post;
  final RatingList _ratingList;

  PostWithLoadedInfo({
    required BlogData post,
    required RatingList ratingList,
  })  : _post = post,
        _ratingList = ratingList;

  BlogData get post => _post;
  RatingList get ratingList => _ratingList;

  factory PostWithLoadedInfo.fromJson(Map<String, Object?> jsonMap) {
    return PostWithLoadedInfo(
      post: BlogData.fromJson(
        jsonMap[KeysForPostWithLoadedInfoJsonConverter.post]
            as Map<String, Object?>,
      ),
      ratingList: RatingList.fromJson(
        jsonMap[KeysForPostWithLoadedInfoJsonConverter.ratingList]
            as Map<String, Object?>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        KeysForPostWithLoadedInfoJsonConverter.post: _post.toJson(),
        KeysForPostWithLoadedInfoJsonConverter.ratingList: _ratingList.toJson(),
      };
}
