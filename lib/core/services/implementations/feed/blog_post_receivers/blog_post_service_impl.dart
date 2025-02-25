import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_receivers/blog_post_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

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
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    return BlogPost.fromJson(jsonDecode(response.data).first);
  }
}
