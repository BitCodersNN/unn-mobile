import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/ajax_action.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_fetcher_service.dart';

class _DataKeys {
  static const String chatId = 'chatId';
  static const String limit = 'limit';
  static const String lastId = 'filter[lastId]';
  static const String orderId = 'order[id]';
}

class _DataValue {
  static const String orderId = 'DESC';
}

class MessageFetcherServiceImpl implements MessageFetcherService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  MessageFetcherServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<List?> fetch({
    required int chatId,
    int limit = 25,
    int? lastMessageId,
  }) async {
    final response = lastMessageId == null
        ? await _fetchFirstMessages(chatId, limit)
        : await _fetchMessages(chatId, lastMessageId, limit);

    if (response == null) {
      return null;
    }

    #TODO;
  }

  Future<Response?> _fetchFirstMessages(
    int chatId,
    int limit,
  ) async {
    return _fetchMessagesFromApi(
      action: AjaxActionStrings.fetchFirstMessage,
      data: {
        _DataKeys.chatId: chatId,
        _DataKeys.limit: limit,
      },
    );
  }

  Future<Response?> _fetchMessages(
    int chatId,
    int lastMessageId,
    int limit,
  ) async {
    return _fetchMessagesFromApi(
      action: AjaxActionStrings.fetchMessage,
      data: {
        _DataKeys.chatId: chatId,
        _DataKeys.limit: limit,
        _DataKeys.lastId: lastMessageId,
        _DataKeys.orderId: _DataValue.orderId,
      },
    );
  }

  Future<Response?> _fetchMessagesFromApi({
    required String action,
    required Map<String, dynamic> data,
  }) async {
    try {
      return await _apiHelper.post(
        path: ApiPath.ajax,
        queryParameters: {
          AjaxActionStrings.actionKey: action,
        },
        data: data,
        options: OptionsWithTimeoutAndExpectedTypeFactory.options(
          10,
          ResponseDataType.jsonMap,
        ),
      );
    } catch (exception, stackTrace) {
      _loggerService.logError(exception, stackTrace);
      return null;
    }
  }
}
