// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/constants/api/ajax_action.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/html_utils/blog_post_comment_html_parser.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/feed/blog_post_comment.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_comments_service.dart';

class _JsonKeys {
  static const _messageListKey = 'messageList';
}

class BlogPostCommentsServiceImpl implements BlogPostCommentsService {
  final LoggerService _loggerService;
  final CurrentUserSyncStorage _currentUserSync;
  final ApiHelper _apiHelper;

  BlogPostCommentsServiceImpl(
    this._loggerService,
    this._currentUserSync,
    this._apiHelper,
  );
  @override
  Future<List<BlogPostComment>?> getBlogPostComments({
    required int postId,
    int pageNumber = 1,
  }) async {
    final Response response;
    try {
      response = await _apiHelper.post(
        path: ApiPath.ajax,
        queryParameters: {
          'mode': 'class',
          AjaxActionStrings.actionKey: AjaxActionStrings.navigateComment,
          AjaxActionStrings.c: AjaxActionStrings.comment,
        },
        data: {
          'ENTITY_XML_ID': 'BLOG_$postId',
          'AJAX_POST': 'Y',
          'MODE': 'LIST',
          'comment_post_id': postId.toString(),
          'PAGEN_1': pageNumber.toString(),
        },
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    final Map<String, dynamic>? bodyAsJson = response.data;
    if (bodyAsJson == null) {
      return null;
    }

    if (!bodyAsJson.containsKey(_JsonKeys._messageListKey)) {
      _loggerService.log(
        'json doesn\'t contain the messageList key',
      );
      return null;
    }

    final htmlBody = bodyAsJson[_JsonKeys._messageListKey] as String;

    return BlogPostCommentHtmlParser.parse(
      htmlBody,
      _currentUserSync.currentUserData ?? UserShortInfo(),
    );
  }
}
