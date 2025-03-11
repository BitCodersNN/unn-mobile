import 'package:unn_mobile/core/models/feed/blog_post_comment.dart';
import 'package:unn_mobile/core/models/feed/blog_post_data.dart';
import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class _BlogPostJsonBitrixKeys {
  static const String author = 'author';
  static const String attach = 'attach';
  static const String comments = 'comments';
  static const String post = 'post';
  static const String ratingList = 'ratingList';
}

class _BlogPostJsonKeys {
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
        jsonMap[_BlogPostJsonKeys.reaction],
      ),
      userShortInfo: UserShortInfo.fromJson(
        jsonMap[_BlogPostJsonKeys.author],
      ),
      attachFiles: (jsonMap[_BlogPostJsonKeys.attach] as List)
          .map((item) => FileData.fromJson(item))
          .toList(),
      comments: (jsonMap[_BlogPostJsonKeys.comments] as List)
          .map((comment) => BlogPostComment.fromJson(comment))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...data.toJson(),
      _BlogPostJsonKeys.reaction: ratingList.toJson(),
      _BlogPostJsonKeys.author: userShortInfo.toJson(),
      _BlogPostJsonKeys.attach:
          attachFiles.map((file) => file.toJson()).toList(),
      _BlogPostJsonKeys.comments:
          comments.map((comment) => comment.toJson()).toList(),
    };
  }

  factory BlogPost.fromJsonLegacy(Map<String, dynamic> jsonMap) {
    return BlogPost._(
      data: BlogPostData.fromJsonLegacy(
        jsonMap[_BlogPostJsonBitrixKeys.post]
            as Map<String, Object?>,
      ),
      ratingList: RatingList.fromJsonLegacy(
        jsonMap[_BlogPostJsonBitrixKeys.ratingList]
            as Map<String, Object?>,
      ),
      userShortInfo: UserShortInfo.fromJsonLegacy(
        jsonMap[_BlogPostJsonBitrixKeys.author],
      ),
      attachFiles: (jsonMap[_BlogPostJsonBitrixKeys.attach] as List)
          .map((item) => FileData.fromBitrixJson(item))
          .toList(),
      comments: (jsonMap[_BlogPostJsonBitrixKeys.comments] as List)
          .map((comment) => BlogPostComment.fromJsonLegacy(comment))
          .toList(),
    );
  }
}
