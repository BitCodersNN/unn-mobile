import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_posts.dart';

class GettingBlogPostsImpl implements GettingBlogPosts {
  final int _numberOfPostsPerPage = 50;
  final String _path = 'rest/log.blogpost.get.json';
  final String _sessid = 'sessid';
  final String _start = 'start';
  final String _sessionIdCookieKey = "PHPSESSID";

  @override
  Future<List<BlogData>?> getBlogPost({int pageNumber = 0}) async {
    final authorisationService =
        Injector.appInstance.get<AuthorisationService>();

    final requstSender = HttpRequestSender(path: _path, queryParams: {
      _sessid: authorisationService.csrf ?? '',
      _start: (_numberOfPostsPerPage * pageNumber).toString(),
    }, cookies: {
      _sessionIdCookieKey: authorisationService.sessionId ?? '',
    });

    HttpClientResponse response;
    try {
      response = await requstSender.get(timeoutSeconds: 60);
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance
          .log("Exception: $error\nStackTrace: $stackTrace");
      return null;
    }

    final statusCode = response.statusCode;

    if (statusCode != 200) {
      return null;
    }

    final str = await HttpRequestSender.responseToStringBody(response);
    dynamic jsonList;
    try {
      jsonList = jsonDecode(str)['result'];
    } catch (erorr, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(erorr, stackTrace);
      return null;
    }

    List<BlogData>? blogPosts;
    try {
      blogPosts = jsonList
          .map<BlogData>((blogPostJson) => BlogData.fromJson(blogPostJson))
          .toList();
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }

    return blogPosts;
  }
}
