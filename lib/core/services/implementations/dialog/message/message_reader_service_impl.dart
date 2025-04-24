// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/ajax_action.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/response_status_validator.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_reader_service.dart';
import 'package:uuid/uuid.dart';

class _DataKeys {
  static const String chatId = 'chatId';
  static const String ids = 'ids';
  static const String actionUuid = 'actionUuid';
}

class MessageReaderServiceImpl implements MessageReaderService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  MessageReaderServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<bool> readMessage({
    required int chatId,
    required int messageId,
  }) async =>
      await readMessages(
        chatId: chatId,
        messageIds: [messageId],
      );

  @override
  Future<bool> readMessages({
    required int chatId,
    required List<int> messageIds,
  }) async {
    Response response;
    try {
      response = await _apiHelper.post(
        path: ApiPath.ajax,
        queryParameters: {
          AjaxActionStrings.actionKey: AjaxActionStrings.readMessage,
        },
        data: _prepareRequestData(chatId, messageIds),
        options: OptionsWithTimeoutAndExpectedTypeFactory.options(
          10,
          ResponseDataType.jsonMap,
        ),
      );
    } catch (exception, stackTrace) {
      _loggerService.logError(exception, stackTrace);
      return false;
    }

    if (!ResponseStatusValidator.validate(response.data, _loggerService)) {
      return false;
    }

    return true;
  }

  Map<String, dynamic> _prepareRequestData(
    int chatId,
    List<int> messageIds,
  ) {
    final requestData = {
      _DataKeys.chatId: chatId,
      _DataKeys.actionUuid: const Uuid().v4(),
    };

    for (int i = 0; i < messageIds.length; i++) {
      requestData['${_DataKeys.ids}[$i]'] = messageIds[i];
    }

    return requestData;
  }
}
