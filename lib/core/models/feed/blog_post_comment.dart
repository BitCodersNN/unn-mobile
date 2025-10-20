// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/models/feed/blog_post_comment_data.dart';
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

  factory BlogPostComment.fromJson(JsonMap jsonMap) => BlogPostComment._(
        data: BlogPostCommentData.fromJson(jsonMap),
        ratingList:
            jsonMap[_BlogPostCommentDataWithRatingsJsonKeys.reaction] != null
                ? RatingList.fromJson(
                    jsonMap[_BlogPostCommentDataWithRatingsJsonKeys.reaction]!
                        as JsonMap,
                  )
                : null,
        userShortInfo: UserShortInfo.fromJson(
          jsonMap[_BlogPostCommentDataWithRatingsJsonKeys.author]! as JsonMap,
        ),
        attachFiles: [
          for (final item
              in jsonMap[_BlogPostCommentDataWithRatingsJsonKeys.attach]!
                  as List)
            FileData.fromJson(item),
        ],
      );

  JsonMap toJson() => {
        ...data.toJson(),
        _BlogPostCommentDataWithRatingsJsonKeys.reaction: ratingList?.toJson(),
        _BlogPostCommentDataWithRatingsJsonKeys.author: userShortInfo.toJson(),
        _BlogPostCommentDataWithRatingsJsonKeys.attach: [
          for (final file in attachFiles) file.toJson(),
        ],
      };

  factory BlogPostComment.fromBitrixJson(JsonMap jsonMap) => BlogPostComment._(
        data: BlogPostCommentData.fromBitrixJson(jsonMap),
        ratingList:
            jsonMap[_BlogPostCommentDataWithRatingsJsonKeys.reaction] != null
                ? RatingList.fromBitrixJson(
                    jsonMap[_BlogPostCommentDataWithRatingsJsonKeys.reaction]!
                        as JsonMap,
                  )
                : null,
        userShortInfo: UserShortInfo.fromBitrixJson(
          jsonMap[_BlogPostCommentDataWithRatingsJsonKeys.author]! as JsonMap,
        ),
        attachFiles: [
          for (final item
              in jsonMap[_BlogPostCommentDataWithRatingsJsonKeys.attach]!
                  as List)
            FileData.fromBitrixJson(item),
        ],
      );
}
