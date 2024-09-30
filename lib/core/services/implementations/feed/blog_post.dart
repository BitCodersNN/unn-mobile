import 'dart:convert';
import 'dart:io';

import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_posts.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class BlogPostsServiceImpl implements BlogPostsService {
  final AuthorizationService _authorisationService;
  final LoggerService _loggerService;

  BlogPostsServiceImpl(
    this._authorisationService,
    this._loggerService,
  );

  @override
  Future<List<BlogData>?> getBlogPosts({
    int? pageNumber,
    int perpage = 50,
  }) async {
    final requestSender = HttpRequestSender(
      path: ApiPaths.blogPostWithLoadedInfo,
      queryParams: {
        'perpage': perpage.toString(),
        'pageNumber': pageNumber.toString(),
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
        'statusCode = $statusCode; perpage = $perpage; pageNumber = $pageNumber;',
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

  List<BlogData>? _parseBlogPostsFromJsonList(List<dynamic> jsonList) {
    List<BlogData>? blogPosts;
    try {
      blogPosts = jsonList.map<BlogData>((jsonMap) {
        Map<String, dynamic> blogPost;
        final blogData = BlogData.fromJsonPortal2(jsonMap);
        final blogRatingList = RatingList.fromJsonPortal2(jsonMap['reaction']);        
        return blogData;
      }).toList();
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
    }

    return blogPosts;
  }
}
