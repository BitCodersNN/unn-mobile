// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/models/feed/blog_post_comment.dart';
import 'package:unn_mobile/core/models/feed/blog_post_data.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class _BlogPostBitrixJsonKeys {
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

  factory BlogPost.fromJson(JsonMap jsonMap) => BlogPost._(
        data: BlogPostData.fromJson(jsonMap),
        ratingList: RatingList.fromJson(
          jsonMap[_BlogPostJsonKeys.reaction]! as JsonMap,
        ),
        userShortInfo: UserShortInfo.fromJson(
          jsonMap[_BlogPostJsonKeys.author]! as JsonMap,
        ),
        attachFiles: [
          for (final item in jsonMap[_BlogPostJsonKeys.attach]! as List)
            FileData.fromJson(item),
        ],
        comments: [
          for (final comment in jsonMap[_BlogPostJsonKeys.comments]! as List)
            BlogPostComment.fromJson(comment),
        ],
      );

  JsonMap toJson() => {
        ...data.toJson(),
        _BlogPostJsonKeys.reaction: ratingList.toJson(),
        _BlogPostJsonKeys.author: userShortInfo.toJson(),
        _BlogPostJsonKeys.attach: [
          for (final file in attachFiles) file.toJson(),
        ],
        _BlogPostJsonKeys.comments: [
          for (final comment in comments) comment.toJson(),
        ],
      };

  factory BlogPost.fromBitrixJson(JsonMap jsonMap) => BlogPost._(
        data: BlogPostData.fromBitrixJson(
          jsonMap[_BlogPostBitrixJsonKeys.post]! as JsonMap,
        ),
        ratingList: RatingList.fromBitrixJson(
          jsonMap[_BlogPostBitrixJsonKeys.ratingList]! as JsonMap,
        ),
        userShortInfo: UserShortInfo.fromBitrixJson(
          jsonMap[_BlogPostBitrixJsonKeys.author]! as JsonMap,
        ),
        attachFiles: [
          for (final item in jsonMap[_BlogPostBitrixJsonKeys.attach]! as List)
            FileData.fromBitrixJson(item),
        ],
        comments: [
          for (final comment
              in jsonMap[_BlogPostBitrixJsonKeys.comments]! as List)
            BlogPostComment.fromBitrixJson(comment),
        ],
      );
}
