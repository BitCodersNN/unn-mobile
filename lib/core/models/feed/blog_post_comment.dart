import 'package:unn_mobile/core/models/feed/blog_post_comment_data.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/models/user_short_info.dart';

class _KeysForBlogPostCommentDataWithRatings {
  static const String author = 'author';
  static const String attach = 'attach';
  static const String reaction = 'reaction';
}

class BlogPostComment {
  final BlogPostCommentData commentData;
  final RatingList? commentRatingList;
  final UserShortInfo commentUserShortInfo;
  final List<FileData> commentAttachFiles;

  BlogPostComment._({
    required this.commentData,
    required this.commentRatingList,
    required this.commentUserShortInfo,
    required this.commentAttachFiles,
  });

  factory BlogPostComment.fromJson(Map<String, dynamic> jsonMap) {
    return BlogPostComment._(
      commentData: BlogPostCommentData.fromJson(jsonMap),
      commentRatingList: jsonMap[_KeysForBlogPostCommentDataWithRatings.reaction] != null
          ? RatingList.fromJson(
              jsonMap[_KeysForBlogPostCommentDataWithRatings.reaction],
            )
          : null,
      commentUserShortInfo: UserShortInfo.fromJson(
        jsonMap[_KeysForBlogPostCommentDataWithRatings.author],
      ),
      commentAttachFiles:
          (jsonMap[_KeysForBlogPostCommentDataWithRatings.attach] as List)
              .map((item) => FileData.fromJson(item))
              .toList(),
    );
  }

  factory BlogPostComment.fromJsonPortal2(Map<String, dynamic> jsonMap) {
    return BlogPostComment._(
      commentData: BlogPostCommentData.fromJsonPortal2(jsonMap),
      commentRatingList: jsonMap[_KeysForBlogPostCommentDataWithRatings.reaction] != null
          ? RatingList.fromJsonPortal2(
              jsonMap[_KeysForBlogPostCommentDataWithRatings.reaction],
            )
          : null,
      commentUserShortInfo: UserShortInfo.fromJsonPortal2(
        jsonMap[_KeysForBlogPostCommentDataWithRatings.author],
      ),
      commentAttachFiles:
          (jsonMap[_KeysForBlogPostCommentDataWithRatings.attach] as List)
              .map((item) => FileData.fromJsonPortal2(item))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...commentData.toJson(),
      _KeysForBlogPostCommentDataWithRatings.reaction: commentRatingList?.toJson(),
      _KeysForBlogPostCommentDataWithRatings.author: commentUserShortInfo.toJson(),
      _KeysForBlogPostCommentDataWithRatings.attach:
          commentAttachFiles.map((file) => file.toJson()).toList(),
    };
  }
}
