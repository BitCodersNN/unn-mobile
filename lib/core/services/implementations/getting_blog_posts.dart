import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';

class GettingBlogPosts {
  final int _numberOfPostsReturnedInRequest = 50;
  final String _path = 'rest/log.blogpost.get.json';
  final String _sessid = 'sessid';
  final String _start = 'start';
  final String _sessionIdCookieKey = "PHPSESSID";

  Future<List<BlogData>?> getBlogPost({int offset = 0}) async {
    final authorisationService =
        Injector.appInstance.get<AuthorisationService>();

    final requstSender = HttpRequestSender(path: _path, queryParams: {
      _sessid: authorisationService.csrf ?? '',
      _start: (_numberOfPostsReturnedInRequest * offset).toString(),
    }, cookies: {
      _sessionIdCookieKey: authorisationService.sessionId ?? '',
    });

    HttpClientResponse response;
    try {
      response = await requstSender.get(timeoutSeconds: 10);
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.log(
          "Exception: $error\nStackTrace: $stackTrace");
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
      await FirebaseCrashlytics.instance
          .recordError(erorr, stackTrace);
      return null;
    }
    List<BlogData> blogPosts = jsonList
        .map((blogPostJson) => BlogData.fromJson(blogPostJson))
        .toList();

    return blogPosts;
  }
}
