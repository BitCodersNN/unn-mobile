import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/rating_list.dart';

class KeysForPostWithLoadedInfoJsonConverter {
  static const String author = 'author';
  static const String post = 'post';
  static const String files = 'files';
  static const String ratingList = 'ratingList';
}

class KeysForPostWithLoadedInfoJsonConverterPortal2 {
  static const String reaction = 'reaction';
}

class PostWithLoadedInfo {
  final BlogData post;
  final RatingList ratingList;

  PostWithLoadedInfo._({
    required this.post,
    required this.ratingList,
  });

  factory PostWithLoadedInfo.fromJson(Map<String, dynamic> jsonMap) {
    return PostWithLoadedInfo._(
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

  factory PostWithLoadedInfo.fromJsonPortal2(Map<String, dynamic> jsonMap) {
    return PostWithLoadedInfo._(
      post: BlogData.fromJsonPortal2(jsonMap),
      ratingList: RatingList.fromJsonPortal2(
        jsonMap[KeysForPostWithLoadedInfoJsonConverterPortal2.reaction],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        KeysForPostWithLoadedInfoJsonConverter.post: post.toJson(),
        KeysForPostWithLoadedInfoJsonConverter.ratingList: ratingList.toJson(),
      };
}
