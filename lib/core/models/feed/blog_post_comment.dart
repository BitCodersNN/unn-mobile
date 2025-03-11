import 'package:unn_mobile/core/models/feed/blog_post_comment_data.dart';
import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class _BlogPostCommentDataWithRatingsJsonKeys {
  static const String author = 'author';
  static const String attach = 'attach';
  static const String reaction = 'reaction';
}

class BlogPostComment {
  final BlogPostCommentData data;
  final RatingList? ratingList;
  final UserShortInfo userShortInfo;
  final List<FileData> attachFiles;

  BlogPostComment._({
    required this.data,
    required this.ratingList,
    required this.userShortInfo,
    required this.attachFiles,
  });

  factory BlogPostComment.fromJson(Map<String, dynamic> jsonMap) {
    return BlogPostComment._(
      data: BlogPostCommentData.fromJson(jsonMap),
      ratingList:
          jsonMap[_BlogPostCommentDataWithRatingsJsonKeys.reaction] != null
              ? RatingList.fromJson(
                  jsonMap[_BlogPostCommentDataWithRatingsJsonKeys.reaction],
                )
              : null,
      userShortInfo: UserShortInfo.fromJson(
        jsonMap[_BlogPostCommentDataWithRatingsJsonKeys.author],
      ),
      attachFiles:
          (jsonMap[_BlogPostCommentDataWithRatingsJsonKeys.attach] as List)
              .map((item) => FileData.fromJson(item))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...data.toJson(),
      _BlogPostCommentDataWithRatingsJsonKeys.reaction: ratingList?.toJson(),
      _BlogPostCommentDataWithRatingsJsonKeys.author: userShortInfo.toJson(),
      _BlogPostCommentDataWithRatingsJsonKeys.attach:
          attachFiles.map((file) => file.toJson()).toList(),
    };
  }

  factory BlogPostComment.fromJsonLegacy(Map<String, dynamic> jsonMap) {
    return BlogPostComment._(
      data: BlogPostCommentData.fromJsonLegacy(jsonMap),
      ratingList:
          jsonMap[_BlogPostCommentDataWithRatingsJsonKeys.reaction] != null
              ? RatingList.fromJsonLegacy(
                  jsonMap[_BlogPostCommentDataWithRatingsJsonKeys.reaction],
                )
              : null,
      userShortInfo: UserShortInfo.fromJsonLegacy(
        jsonMap[_BlogPostCommentDataWithRatingsJsonKeys.author],
      ),
      attachFiles:
          (jsonMap[_BlogPostCommentDataWithRatingsJsonKeys.attach] as List)
              .map((item) => FileData.fromBitrixJson(item))
              .toList(),
    );
  }
}
