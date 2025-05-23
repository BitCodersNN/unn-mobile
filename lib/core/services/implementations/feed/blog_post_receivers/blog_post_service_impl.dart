// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_receivers/blog_post_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class _QueryParamNames {
  static const id = 'id';
}

class BlogPostServiceImpl implements BlogPostService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  BlogPostServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<BlogPost?> getBlogPost({required int id}) async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: ApiPath.blogPostWithLoadedInfo,
        queryParameters: {
          _QueryParamNames.id: id,
        },
        options: OptionsWithTimeoutAndExpectedTypeFactory.options(
          30,
          ResponseDataType.list,
        ),
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    return BlogPost.fromJson(response.data.first);
  }
}
