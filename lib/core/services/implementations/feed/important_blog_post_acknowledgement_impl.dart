import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/blog_post_response_validator.dart';
import 'package:unn_mobile/core/services/interfaces/feed/important_blog_post_acknowledgement.dart';
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
        path: ApiPaths.ajax,
        queryParameters: {
          AjaxActionStrings.actionKey: AjaxActionStrings.readImportantBlogPost,
        },
        data: {
          _DataKeys.postId: postId,
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
    return BlogPostResponseValidator.validate(response.data, _loggerService);
  }
}
