import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/authenticated_api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/misc/objects_with_pagination.dart';
import 'package:unn_mobile/core/models/dialog/dialog.dart';
import 'package:unn_mobile/core/models/dialog/dialog_query_parameter.dart';
import 'package:unn_mobile/core/models/dialog/group_dialog.dart';
import 'package:unn_mobile/core/models/dialog/user_dialog.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/dialog_service.dart';

class _DataKeys {
  static const String sessid = 'sessid';
}

class _ResponseJsonKeys {
  static const String result = 'result';
  static const String items = 'items';
  static const String type = 'type';
  static const String chat = 'chat';
  static const String user = 'user';
}

class DialogServiceImpl implements DialogService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  DialogServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<PartialResult<Dialog>?> dialog({
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

    final dialogs = parseJsonIterable<Dialog>(
      response.data[_ResponseJsonKeys.result][_ResponseJsonKeys.items],
      (json) {
        final type = json[_ResponseJsonKeys.type] as String;
        switch (type) {
          case _ResponseJsonKeys.chat:
            return GroupDialog.fromJson(json);
          case _ResponseJsonKeys.user:
            return UserDialog.fromJson(json);
          default:
            throw FormatException('Unknown dialog type: $type');
        }
      },
      _loggerService,
    );

    return PartialResult(
      items: dialogs,
      hasMore: response.data[_ResponseJsonKeys.result]
          [PartialResultJsonKeys.hasMore],
    );
  }
}
