import 'package:unn_mobile/core/models/blog_post_comment.dart';
import 'package:unn_mobile/core/models/rating_list.dart';

class _KeysForLoadedBlogPostCommentJson {
  static const String reaction = 'reaction';
}

class LoadedBlogPostComment {
  final BlogPostComment comment;
  final RatingList? ratingList;

  LoadedBlogPostComment._({
    required this.comment,
    required this.ratingList,
  });

  factory LoadedBlogPostComment.fromJson(Map<String, dynamic> json) {
    return LoadedBlogPostComment._(
      comment: BlogPostComment.fromJson(json),
      ratingList: json[_KeysForLoadedBlogPostCommentJson.reaction] != null
          ? RatingList.fromJson(
              json[_KeysForLoadedBlogPostCommentJson.reaction],
            )
          : null,
    );
  }

  factory LoadedBlogPostComment.fromJsonPortal2(Map<String, dynamic> json) {
    return LoadedBlogPostComment._(
      comment: BlogPostComment.fromJsonPortal2(json),
      ratingList: json[_KeysForLoadedBlogPostCommentJson.reaction] != null
          ? RatingList.fromJsonPortal2(
              json[_KeysForLoadedBlogPostCommentJson.reaction],
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...comment.toJson(),
      _KeysForLoadedBlogPostCommentJson.reaction: ratingList?.toJson(),
    };
  }
}
