// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/feed/blog_post.dart';

class _ImportantBlogPostJsonKeys {
  static const String isRead = 'isRead';
  static const String readCount = 'readCount';
}

class ImportantBlogPost extends BlogPost {
  final bool isRead;
  final int readCount;

  ImportantBlogPost({
    required super.data,
    required super.ratingList,
    required super.userShortInfo,
    required super.attachFiles,
    required super.comments,
    required super.commentCount,
    required this.isRead,
    required this.readCount,
  });

  ImportantBlogPost.fromBlogPost({
    required BlogPost blogPost,
    required this.isRead,
    required this.readCount,
  }) : super(
          data: blogPost.data,
          ratingList: blogPost.ratingList,
          userShortInfo: blogPost.userShortInfo,
          attachFiles: blogPost.attachFiles,
          comments: blogPost.comments,
          commentCount: blogPost.commentCount,
        );

  factory ImportantBlogPost.fromJson(JsonMap jsonMap) =>
      ImportantBlogPost.fromBlogPost(
        blogPost: BlogPost.fromJson(jsonMap),
        isRead: jsonMap[_ImportantBlogPostJsonKeys.isRead]! as bool,
        readCount: jsonMap[_ImportantBlogPostJsonKeys.readCount]! as int,
      );

  @override
  JsonMap toJson() => {
        ...super.toJson(),
        _ImportantBlogPostJsonKeys.isRead: isRead,
        _ImportantBlogPostJsonKeys.readCount: readCount,
      };
}
