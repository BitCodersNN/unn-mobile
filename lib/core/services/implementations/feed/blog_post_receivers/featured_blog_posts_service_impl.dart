import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/models/feed/blog_post_type.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_receivers/featured_blog_post_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class FeaturedBlogPostsServiceImpl implements FeaturedBlogPostsService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  FeaturedBlogPostsServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<Map<BlogPostType, List<BlogPost>>?> getFeaturedBlogPosts() async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: ApiPath.featuredBlogPostWithLoadedInfo,
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

  Map<BlogPostType, List<BlogPost>>? _parseBlogPostsFromJsonList(
    List<dynamic> jsonList,
  ) {
    final Map<BlogPostType, List<BlogPost>> blogPosts = {};

    for (final jsonMap in jsonList) {
      BlogPost blogPost;
      try {
        blogPost = BlogPost.fromJson(jsonMap);
      } catch (error, stackTrace) {
        _loggerService.log(
          'Failed to parse BlogPost from jsonMap: $jsonMap  Exception: $error\nStackTrace: $stackTrace',
        );
        continue;
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
