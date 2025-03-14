import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/authenticated_api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/models/dialog/dialog_query_parameter.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class _DataKeys {
  static const String sessid = 'sessid';
}

class DialogServiceImpl {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  DialogServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  Future<List?> dialog({
    dialogQueryParameter = const DialogQueryParameter(
      limit: 5,
    ),
  }) async {
    Response response;
    try {
      response = await _apiHelper.post(
        path: ApiPath.dialog,
        data: Map.from(dialogQueryParameter.toJson())
          ..addAll(
            {
              _DataKeys.sessid:
                  (_apiHelper as AuthenticatedApiHelper).sessionId,
            },
          ),
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
