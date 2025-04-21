import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/ajax_action.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/response_status_validator.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_updater_service.dart';

class _DataKeys {
  static const String id = 'id';
  static const String message = 'fields[message]';
}

class _JsonKeys {
  static const String data = 'id';
}

class MessageUpdaterServiceImpl implements MessageUpdaterService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  MessageUpdaterServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<bool> update({
    required int messageId,
    required String text,
  }) async {
    Response response;
    try {
      response = await _apiHelper.post(
        path: ApiPath.ajax,
        queryParameters: {
          AjaxActionStrings.actionKey: AjaxActionStrings.updateMessage,
        },
        data: {
          _DataKeys.id: messageId,
          _DataKeys.message: text,
        },
        options: OptionsWithTimeoutAndExpectedTypeFactory.options(
          10,
          ResponseDataType.jsonMap,
        ),
      );
    } catch (exception, stackTrace) {
      _loggerService.logError(exception, stackTrace);
      return false;
    }

    ResponseStatusValidator.validate(response.data, _loggerService);

    if (!ResponseStatusValidator.validate(response.data, _loggerService)) {
      return false;
    }

    return response.data[_JsonKeys.data];
  }
}
