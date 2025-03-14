import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/ajax_action.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class _DataKeys {
  static const String chatId = 'chatId';
  static const String limit = 'limit';
}

class MessageServiceImpl {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  MessageServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  Future<List?> message({
    required int chatId,
    int limit = 25,
  }) async {
    Response response;
    try {
      response = await _apiHelper.post(
        path: ApiPath.ajax,
        queryParameters: {
          AjaxActionStrings.actionKey: AjaxActionStrings.message,
        },
        data: {
          _DataKeys.chatId: chatId,
          _DataKeys.limit: limit,
        },
        options: OptionsWithTimeoutAndExpectedTypeFactory.options(
          10,
          ResponseDataType.jsonMap,
        ),
      );
    } catch (exception, stackTrace) {
      _loggerService.logError(exception, stackTrace);
      return null;
    }

    return null;  # TODO;
  }
}
