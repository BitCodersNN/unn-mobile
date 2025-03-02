import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/ajax_action.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/blog_post_response_validator.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/services/interfaces/feed/featured_blog_post_action/important_blog_post_acknowledgement_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class _DataKeys {
  static const String postId = 'params[POST_ID]';
}

class ImportantBlogPostAcknowledgementServiceImpl
    implements ImportantBlogPostAcknowledgementService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  ImportantBlogPostAcknowledgementServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<bool> read(int postId) async {
    Response response;
    try {
      response = await _apiHelper.post(
        path: ApiPath.ajax,
        queryParameters: {
          AjaxActionStrings.actionKey: AjaxActionStrings.readImportantBlogPost,
        },
        data: {
          _DataKeys.postId: postId,
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
