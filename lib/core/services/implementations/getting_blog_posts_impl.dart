import 'dart:convert';
import 'dart:io';

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_posts.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class GettingBlogPostsImpl implements GettingBlogPosts {
  final LoggerService _loggerService =
      Injector.appInstance.get<LoggerService>();
  final int _numberOfPostsPerPage = 50;
  final String _start = 'start';
  final String _postId = 'POST_ID';

  @override
  Future<List<BlogData>?> getBlogPosts({
    int pageNumber = 0,
    int? postId,
  }) async {
    final authorisationService =
        Injector.appInstance.get<AuthorisationService>();

    final requestSender = HttpRequestSender(
      path: ApiPaths.blogpostGet,
      queryParams: {
        SessionIdentifierStrings.sessid: authorisationService.csrf ?? '',
        _start: (_numberOfPostsPerPage * pageNumber).toString(),
        _postId: postId.toString(),
      },
      cookies: {
        SessionIdentifierStrings.sessionIdCookieKey:
            authorisationService.sessionId ?? '',
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
        '${runtimeType.toString()}: statusCode = $statusCode; pageNumber = $pageNumber; postId = $postId',
      );
      return null;
    }

    final str = await HttpRequestSender.responseToStringBody(response);
    dynamic jsonList;
    try {
      jsonList = jsonDecode(str)['result'];
    } catch (erorr, stackTrace) {
      _loggerService.logError(erorr, stackTrace);
      return null;
    }

    List<BlogData>? blogPosts;
    try {
      blogPosts = jsonList
          .map<BlogData>((blogPostJson) => BlogData.fromJson(blogPostJson))
          .toList();
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
    }

    if (blogPosts != null) {
      blogPosts.sort((a, b) => b.datePublish.compareTo(a.datePublish));
    }

    return blogPosts;
  }
}
