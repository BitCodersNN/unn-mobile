import 'package:unn_mobile/core/models/feed/blog_post_comment.dart';
import 'package:unn_mobile/core/models/feed/blog_post_data.dart';
import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class _KeysForBlogPostJsonConverterLegacy {
  static const String author = 'author';
  static const String attach = 'attach';
  static const String comments = 'comments';
  static const String post = 'post';
  static const String ratingList = 'ratingList';
}

class _KeysForBlogPostJsonConverter {
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
      data: BlogPostData.fromJson(jsonMap),
      ratingList: RatingList.fromJson(
        jsonMap[_KeysForBlogPostJsonConverter.reaction],
      ),
      userShortInfo: UserShortInfo.fromJson(
        jsonMap[_KeysForBlogPostJsonConverter.author],
      ),
      attachFiles: (jsonMap[_KeysForBlogPostJsonConverter.attach] as List)
          .map((item) => FileData.fromJson(item))
          .toList(),
      comments: (jsonMap[_KeysForBlogPostJsonConverter.comments] as List)
          .map((comment) => BlogPostComment.fromJson(comment))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...data.toJson(),
      _KeysForBlogPostJsonConverter.reaction: ratingList.toJson(),
      _KeysForBlogPostJsonConverter.author: userShortInfo.toJson(),
      _KeysForBlogPostJsonConverter.attach:
          attachFiles.map((file) => file.toJson()).toList(),
      _KeysForBlogPostJsonConverter.comments:
          comments.map((comment) => comment.toJson()).toList(),
    };
  }

  factory BlogPost.fromJsonLegacy(Map<String, dynamic> jsonMap) {
    return BlogPost._(
      data: BlogPostData.fromJsonLegacy(
        jsonMap[_KeysForBlogPostJsonConverterLegacy.post]
            as Map<String, Object?>,
      ),
      ratingList: RatingList.fromJsonLegacy(
        jsonMap[_KeysForBlogPostJsonConverterLegacy.ratingList]
            as Map<String, Object?>,
      ),
      userShortInfo: UserShortInfo.fromJsonLegacy(
        jsonMap[_KeysForBlogPostJsonConverterLegacy.author],
      ),
      attachFiles: (jsonMap[_KeysForBlogPostJsonConverterLegacy.attach] as List)
          .map((item) => FileData.fromJsonLegacy(item))
          .toList(),
      comments: (jsonMap[_KeysForBlogPostJsonConverterLegacy.comments] as List)
          .map((comment) => BlogPostComment.fromJsonLegacy(comment))
          .toList(),
    );
  }
}
