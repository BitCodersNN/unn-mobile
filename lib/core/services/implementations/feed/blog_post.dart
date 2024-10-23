import 'dart:convert';
import 'dart:io';

import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_posts.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class BlogPostsServiceImpl implements BlogPostsService {
  final AuthorizationService _authorisationService;
  final LoggerService _loggerService;
  final String _numpage = 'numpage';
  final String _perpage = 'perpage';

  BlogPostsServiceImpl(
    this._authorisationService,
    this._loggerService,
  );

  @override
  Future<List<BlogPost>?> getBlogPosts({
    int pageNumber = 1,
    int perpage = 50,
  }) async {
    final requestSender = HttpRequestSender(
      path: ApiPaths.blogPostWithLoadedInfo,
      queryParams: {
        _numpage: pageNumber.toString(),
        _perpage: perpage.toString(),
      },
      cookies: {
        SessionIdentifierStrings.sessionIdCookieKey:
            _authorisationService.sessionId ?? '',
      },
    );

    HttpClientResponse response;
    try {
      response = await requestSender.get(timeoutSeconds: 60);
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    final statusCode = response.statusCode;

    if (statusCode != 200) {
      _loggerService.log(
        'statusCode = $statusCode; $_perpage = $perpage; $_numpage = $pageNumber;',
      );
      return null;
    }

    List<dynamic> jsonList;

    try {
      jsonList =
          jsonDecode(await HttpRequestSender.responseToStringBody(response));
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
