// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/html_utils/blog_post_html_parser.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class BlogPostDetailServiceImpl {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;
  final CurrentUserSyncStorage _currentUserSync;

  BlogPostDetailServiceImpl(
    this._loggerService,
    this._apiHelper,
    this._currentUserSync,
  );

  Future<BlogPost?> getBlogPostById({
    required int postId,
  }) async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: '${ApiPath.blogPost}/$postId/',
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    return BlogPostHtmlParser.parsePost(
      response.data,
      _currentUserSync.currentUserData ?? UserShortInfo(),
    );
  }
}
