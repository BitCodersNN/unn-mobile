import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/models/feed/blog_post_type.dart';
import 'package:unn_mobile/core/services/interfaces/feed/featured_blog_post.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class FeaturedBlogPostServiceImpl implements FeaturedBlogPostService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  FeaturedBlogPostServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<Map<BlogPostType, List<BlogPost>>?> getFeaturedBlogPosts() async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: ApiPaths.featuredBlogPostWithLoadedInfo,
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

  Map<BlogPostType, List<BlogPost>>? _parseBlogPostsFromJsonList(
    List<dynamic> jsonList,
  ) {
    final Map<BlogPostType, List<BlogPost>> blogPosts = {};

    for (final jsonMap in jsonList) {
      BlogPost blogPost;
      try {
        blogPost = BlogPost.fromJsonPortal2(jsonMap);
      } catch (error, stackTrace) {
        _loggerService.logError(error, stackTrace);
        return null;
      }

      if (jsonMap[BlogPostType.pinned.stringValue]) {
        blogPosts.putIfAbsent(BlogPostType.pinned, () => []).add(blogPost);
      } else if (jsonMap[BlogPostType.important.stringValue]) {
        blogPosts.putIfAbsent(BlogPostType.important, () => []).add(blogPost);
      }
    }

    return blogPosts;
  }
}
