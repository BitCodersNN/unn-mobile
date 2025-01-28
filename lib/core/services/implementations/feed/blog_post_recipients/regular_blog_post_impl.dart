import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_recipients/regular_blog_posts.dart';
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
        path: ApiPaths.blogPostWithLoadedInfo,
        queryParameters: {
          _QueryParamNames.numPage: pageNumber.toString(),
          _QueryParamNames.perPage: postsPerPage.toString(),
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
