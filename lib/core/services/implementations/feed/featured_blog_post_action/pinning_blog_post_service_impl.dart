import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/blog_post_response_validator.dart';
import 'package:unn_mobile/core/services/interfaces/feed/featured_blog_post_action/pinning_blog_post_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class _DataKeys {
  static const String logId = 'params[logId]';
}

class PinningBlogPostServiceImpl implements PinningBlogPostService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  PinningBlogPostServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<bool> pin(int pinnedId) async {
    return await _updatePostPinStatus(
      pinnedId,
      AnalyticsLabel.pinBlogPost,
      AjaxActionStrings.pinBlogPost,
    );
  }

  @override
  Future<bool> unpin(int pinnedId) async {
    return await _updatePostPinStatus(
      pinnedId,
      AnalyticsLabel.unpinBlogPost,
      AjaxActionStrings.unpinBlogPost,
    );
  }

  Future<bool> _updatePostPinStatus(
    int pinnedId,
    String b24statAction,
    String actionKey,
  ) async {
    Response response;
    try {
      response = await _apiHelper.post(
        path: ApiPaths.ajax,
        queryParameters: {
          AnalyticsLabel.b24statAction: b24statAction,
          AjaxActionStrings.actionKey: actionKey,
        },
        data: {
          _DataKeys.logId: pinnedId,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return false;
    }

    return FeedResponseValidator.validate(response.data, _loggerService);
  }
}
