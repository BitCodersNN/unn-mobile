import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/ajax_action.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/api/analytics_label.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/blog_post_response_validator.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/options_factory/options_with_timeout_and_expected_type_factory.dart';
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
        path: ApiPath.ajax,
        queryParameters: {
          AnalyticsLabel.b24statAction: b24statAction,
          AjaxActionStrings.actionKey: actionKey,
        },
        data: {
          _DataKeys.logId: pinnedId,
        },
        options: OptionsWithTimeoutAndExpectedTypeFactory.options(
          10,
          ResponseDataType.jsonMap,
        ),
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return false;
    }

    return FeedResponseValidator.validate(response.data, _loggerService);
  }
}
