import 'dart:convert';
import 'dart:io';

import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_posts.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class GettingBlogPostsImpl implements GettingBlogPosts {
  final AuthorizationService authorisationService;
  final LoggerService loggerService;
  final int _numberOfPostsPerPage = 50;
  final String _start = 'start';
  final String _postId = 'POST_ID';

  GettingBlogPostsImpl(
    this.authorisationService,
    this.loggerService,
  );

  @override
  Future<List<BlogData>?> getBlogPosts({
    int pageNumber = 0,
    int? postId,
  }) async {
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
      loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    final statusCode = response.statusCode;

    if (statusCode != 200) {
      loggerService.log(
        'statusCode = $statusCode; pageNumber = $pageNumber; postId = $postId;',
      );
      return null;
    }

    final str = await HttpRequestSender.responseToStringBody(response);
    dynamic jsonList;
    try {
      jsonList = jsonDecode(str)['result'];
    } catch (erorr, stackTrace) {
      loggerService.logError(erorr, stackTrace);
      return null;
    }

    List<BlogData>? blogPosts;
    try {
      blogPosts = jsonList
          .map<BlogData>((blogPostJson) => BlogData.fromJson(blogPostJson))
          .toList();
    } catch (error, stackTrace) {
      loggerService.logError(error, stackTrace);
    }

    if (blogPosts != null) {
      blogPosts.sort((a, b) => b.datePublish.compareTo(a.datePublish));
    }

    return blogPosts;
  }
}
