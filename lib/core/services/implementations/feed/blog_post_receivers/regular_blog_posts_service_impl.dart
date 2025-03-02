import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_receivers/regular_blog_posts_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class _QueryParamNames {
  static const numPage = 'numpage';
  static const perPage = 'perpage';
}

class RegularBlogPostsServiceImpl implements RegularBlogPostsService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  RegularBlogPostsServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<List<BlogPost>?> getRegularBlogPosts({
    int pageNumber = 1,
    int postsPerPage = 20,
  }) async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: ApiPath.blogPostWithLoadedInfo,
        queryParameters: {
          _QueryParamNames.numPage: pageNumber.toString(),
          _QueryParamNames.perPage: postsPerPage.toString(),
        },
        options: OptionsWithTimeoutAndExpectedTypeFactory.options(
          30,
          ResponseDataType.string,
        ),
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    final blogPosts = _parseBlogPostsFromJsonList(jsonDecode(response.data));

    return blogPosts;
  }

  List<BlogPost>? _parseBlogPostsFromJsonList(List<dynamic> jsonList) {
    List<BlogPost>? blogPosts;

    blogPosts = jsonList
        .map<BlogPost?>((jsonMap) {
          try {
            return BlogPost.fromJson(jsonMap);
          } catch (error, stackTrace) {
            _loggerService.log(
              'Failed to parse BlogPost from jsonMap: $jsonMap  Exception: $error\nStackTrace: $stackTrace',
            );
            return null;
          }
        })
        .whereType<BlogPost>()
        .toList();

    return blogPosts;
  }
}
