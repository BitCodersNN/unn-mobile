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
  final BlogPostData data;
  final RatingList ratingList;
  final UserShortInfo userShortInfo;
  final List<FileData> attachFiles;
  final List<BlogPostComment> comments;

  BlogPost._({
    required this.data,
    required this.ratingList,
    required this.userShortInfo,
    required this.attachFiles,
    required this.comments,
  });

  factory BlogPost.fromJson(Map<String, dynamic> jsonMap) {
    return BlogPost._(
      data: BlogPostData.fromJson(
        jsonMap[_KeysForBlogPostJsonConverter.post] as Map<String, Object?>,
      ),
      ratingList: RatingList.fromJson(
        jsonMap[_KeysForBlogPostJsonConverter.ratingList]
            as Map<String, Object?>,
      ),
      userShortInfo:
          UserShortInfo.fromJson(jsonMap[_KeysForBlogPostJsonConverter.author]),
      attachFiles: (jsonMap[_KeysForBlogPostJsonConverter.attach] as List)
          .map((item) => FileData.fromJson(item))
          .toList(),
      comments: (jsonMap[_KeysForBlogPostJsonConverter.comments] as List)
          .map((comment) => BlogPostComment.fromJson(comment))
          .toList(),
    );
  }

  factory BlogPost.fromJsonPortal2(Map<String, dynamic> jsonMap) {
    return BlogPost._(
      data: BlogPostData.fromJsonPortal2(jsonMap),
      ratingList: RatingList.fromJsonPortal2(
        jsonMap[_KeysForBlogPostJsonConverterPortal2.reaction],
      ),
      userShortInfo: UserShortInfo.fromJsonPortal2(
        jsonMap[_KeysForBlogPostJsonConverterPortal2.author],
      ),
      attachFiles:
          (jsonMap[_KeysForBlogPostJsonConverterPortal2.attach] as List)
              .map((item) => FileData.fromJsonPortal2(item))
              .toList(),
      comments: (jsonMap[_KeysForBlogPostJsonConverterPortal2.comments] as List)
          .map((comment) => BlogPostComment.fromJsonPortal2(comment))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _KeysForBlogPostJsonConverter.post: data.toJson(),
      _KeysForBlogPostJsonConverter.ratingList: ratingList.toJson(),
      _KeysForBlogPostJsonConverter.author: userShortInfo.toJson(),
      _KeysForBlogPostJsonConverter.attach:
          attachFiles.map((file) => file.toJson()).toList(),
      _KeysForBlogPostJsonConverter.comments:
          comments.map((comment) => comment.toJson()).toList(),
    };
  }
}
