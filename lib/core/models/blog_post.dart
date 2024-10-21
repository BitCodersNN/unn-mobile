import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/models/loaded_blog_post_comment.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/models/user_short_info.dart';

class _KeysForBlogPostJson {
  static const String author = 'author';
  static const String attach = 'attach';
  static const String comments = 'comments';
}

class BlogPost {
  final PostWithLoadedInfo postWithLoadedInfo;
  final UserShortInfo blogUserShortInfo;
  final List<FileData> blogAttachFiles;
  final List<LoadedBlogPostComment> blogComments;

  BlogPost._({
    required this.postWithLoadedInfo,
    required this.blogUserShortInfo,
    required this.blogAttachFiles,
    required this.blogComments,
  });

  factory BlogPost.fromJson(Map<String, dynamic> jsonMap) {
    return BlogPost._(
      postWithLoadedInfo: PostWithLoadedInfo.fromJson(jsonMap),
      blogUserShortInfo:
          UserShortInfo.fromJson(jsonMap[_KeysForBlogPostJson.author]),
      blogAttachFiles: (jsonMap[_KeysForBlogPostJson.attach] as List)
          .map((item) => FileData.fromJson(item))
          .toList(),
      blogComments: (jsonMap[_KeysForBlogPostJson.comments] as List)
          .map((comment) => LoadedBlogPostComment.fromJson(comment))
          .toList(),
    );
  }

  factory BlogPost.fromJsonPortal2(Map<String, dynamic> jsonMap) {
    return BlogPost._(
      postWithLoadedInfo: PostWithLoadedInfo.fromJsonPortal2(jsonMap),
      blogUserShortInfo:
          UserShortInfo.fromJsonPortal2(jsonMap[_KeysForBlogPostJson.author]),
      blogAttachFiles: (jsonMap[_KeysForBlogPostJson.attach] as List)
          .map((item) => FileData.fromJsonPortal2(item))
          .toList(),
      blogComments: (jsonMap[_KeysForBlogPostJson.comments] as List)
          .map((comment) => LoadedBlogPostComment.fromJsonPortal2(comment))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...postWithLoadedInfo.toJson(),
      _KeysForBlogPostJson.author: blogUserShortInfo.toJson(),
      _KeysForBlogPostJson.attach:
          blogAttachFiles.map((file) => file.toJson()).toList(),
      _KeysForBlogPostJson.comments:
          blogComments.map((comment) => comment.toJson()).toList(),
    };
  }
}
