import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/base_api_helper.dart';
import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_posts.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class _QueryParamNames {
  static const numPage = 'numpage';
  static const perPage = 'perpage';
}

class BlogPostsServiceImpl implements BlogPostsService {
  final LoggerService _loggerService;
  final BaseApiHelper _baseApiHelper;

  BlogPostsServiceImpl(
    this._loggerService,
    this._baseApiHelper,
  );

  @override
  Future<List<BlogPost>?> getBlogPosts({
    int pageNumber = 1,
    int postsPerPage = 20,
  }) async {
    Response response;
    try {
      response = await _baseApiHelper.get(
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

    List<dynamic> jsonList;

    try {
      jsonList = response.data;
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    final blogPosts = _parseBlogPostsFromJsonList(jsonList);

    return blogPosts;
  }

  List<BlogPost>? _parseBlogPostsFromJsonList(List<dynamic> jsonList) {
    List<BlogPost>? blogPosts;

    try {
      blogPosts = jsonList.map<BlogPost>((jsonMap) {
        return BlogPost.fromJsonPortal2(jsonMap);
      }).toList();
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
    }

    return blogPosts;
  }
}
