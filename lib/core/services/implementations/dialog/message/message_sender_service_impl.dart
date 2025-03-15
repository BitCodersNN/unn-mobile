import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/ajax_action.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_sender_service.dart';
import 'package:uuid/uuid.dart';

class _DataKeys {
  static const String dialogId = 'dialogId';
  static const String message = 'fields[message]';
  static const String templateId = 'fields[templateId]';
}

class MessageSenderServiceImpl implements MessageSenderService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  MessageSenderServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<int?> send({
    required String dialogId,
    required String text,
  }) async {
    Response response;
    try {
      response = await _apiHelper.post(
        path: ApiPath.ajax,
        queryParameters: {
          AjaxActionStrings.actionKey: AjaxActionStrings.sendMessage,
        },
        data: {
          _DataKeys.dialogId: dialogId,
          _DataKeys.message: text,
          _DataKeys.templateId: const Uuid().v4(),
        },
      );
    } catch (exception, stackTrace) {
      _loggerService.logError(exception, stackTrace);
      return null;
    }

    return null;
    #TODO;
  }
}
