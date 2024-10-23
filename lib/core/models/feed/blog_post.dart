import 'package:unn_mobile/core/models/feed/blog_post_comment.dart';
import 'package:unn_mobile/core/models/feed/blog_post_data.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/models/user_short_info.dart';

class _KeysForBlogPostJsonConverter {
  static const String author = 'author';
  static const String attach = 'attach';
  static const String comments = 'comments';
  static const String post = 'post';
  static const String ratingList = 'ratingList';
}

class _KeysForBlogPostJsonConverterPortal2 {
  static const String author = 'author';
  static const String attach = 'attach';
  static const String comments = 'comments';
  static const String reaction = 'reaction';
}

class BlogPost {
  final BlogPostData blogPostData;
  final RatingList blogPostRatingList;
  final UserShortInfo blogUserShortInfo;
  final List<FileData> blogAttachFiles;
  final List<BlogPostComment> blogComments;

  BlogPost._({
    required this.blogPostData,
    required this.blogPostRatingList,
    required this.blogUserShortInfo,
    required this.blogAttachFiles,
    required this.blogComments,
  });

  factory BlogPost.fromJson(Map<String, dynamic> jsonMap) {
    return BlogPost._(
      blogPostData: BlogPostData.fromJson(
        jsonMap[_KeysForBlogPostJsonConverter.post] as Map<String, Object?>,
      ),
      blogPostRatingList: RatingList.fromJson(
        jsonMap[_KeysForBlogPostJsonConverter.ratingList]
            as Map<String, Object?>,
      ),
      blogUserShortInfo:
          UserShortInfo.fromJson(jsonMap[_KeysForBlogPostJsonConverter.author]),
      blogAttachFiles: (jsonMap[_KeysForBlogPostJsonConverter.attach] as List)
          .map((item) => FileData.fromJson(item))
          .toList(),
      blogComments: (jsonMap[_KeysForBlogPostJsonConverter.comments] as List)
          .map((comment) => BlogPostComment.fromJson(comment))
          .toList(),
    );
  }

  factory BlogPost.fromJsonPortal2(Map<String, dynamic> jsonMap) {
    return BlogPost._(
      blogPostData: BlogPostData.fromJsonPortal2(jsonMap),
      blogPostRatingList: RatingList.fromJsonPortal2(
        jsonMap[_KeysForBlogPostJsonConverterPortal2.reaction],
      ),
      blogUserShortInfo: UserShortInfo.fromJsonPortal2(
        jsonMap[_KeysForBlogPostJsonConverterPortal2.author],
      ),
      blogAttachFiles:
          (jsonMap[_KeysForBlogPostJsonConverterPortal2.attach] as List)
              .map((item) => FileData.fromJsonPortal2(item))
              .toList(),
      blogComments:
          (jsonMap[_KeysForBlogPostJsonConverterPortal2.comments] as List)
              .map((comment) => BlogPostComment.fromJsonPortal2(comment))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _KeysForBlogPostJsonConverter.post: blogPostData.toJson(),
      _KeysForBlogPostJsonConverter.ratingList: blogPostRatingList.toJson(),
      _KeysForBlogPostJsonConverter.author: blogUserShortInfo.toJson(),
      _KeysForBlogPostJsonConverter.attach:
          blogAttachFiles.map((file) => file.toJson()).toList(),
      _KeysForBlogPostJsonConverter.comments:
          blogComments.map((comment) => comment.toJson()).toList(),
    };
  }
}
