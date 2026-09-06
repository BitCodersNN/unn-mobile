// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/string_keys/session_identifier_keys.dart';
import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/feed/blog_post_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/unn_authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/legacy/legacy_blog_post_service.dart';

class _QueryParamNames {
  static const start = 'start';
  static const _postId = 'POST_ID';
}

@Deprecated(
  'Устаревший способ получения постов, требующий каскадных запросов для полной информации.',
)
class BlogPostServiceImpl implements BlogPostService {
  final UnnAuthService _authorizationService;
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;
  final int _numberOfPostsPerPage = 50;

  BlogPostServiceImpl(
    this._authorizationService,
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<List<BlogPostData>?> getBlogPosts({
    int pageNumber = 0,
    int? postId,
  }) async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: ApiPath.blogPostGet,
        queryParameters: {
          SessionIdentifierKeys.sessid: _authorizationService.csrf ?? '',
          _QueryParamNames.start:
              (_numberOfPostsPerPage * pageNumber).toString(),
          _QueryParamNames._postId: postId.toString(),
        },
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    Iterable jsonList;
    try {
      jsonList = (response.data as JsonMap)['result']! as Iterable;
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    final blogPosts = parseJsonIterable<BlogPostData>(
      jsonList,
      BlogPostData.fromBitrixJson,
      _loggerService,
    )..sort((a, b) => b.datePublish.compareTo(a.datePublish));

    return blogPosts;
  }
}
