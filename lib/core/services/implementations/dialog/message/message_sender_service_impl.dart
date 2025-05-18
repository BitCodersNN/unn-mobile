// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/ajax_action.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/response_status_validator.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_sender_service.dart';
import 'package:uuid/uuid.dart';

class _DataKeys {
  static const String dialogId = 'dialogId';
  static const String message = 'fields[message]';
  static const String templateId = 'fields[templateId]';
  static const String replyId = 'fields[replyId]';
  static String get forwardId => 'fields[forwardIds][${const Uuid().v4()}]';
}

class _JsonKeys {
  static const String data = 'data';
  static const String id = 'id';
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
  }) =>
      _sendMessage(
        dialogId: dialogId,
        text: text,
      );

  @override
  Future<int?> reply({
    required String dialogId,
    required String text,
    required int replyMessageId,
  }) =>
      _sendMessage(
        dialogId: dialogId,
        text: text,
        replyMessageId: replyMessageId,
      );

  @override
  Future<int?> forward({
    required String dialogId,
    required String? text,
    required int forwardMessageId,
  }) =>
      forwardMultiple(
        dialogId: dialogId,
        text: text,
        forwardMessageIds: [forwardMessageId],
      );

  @override
  Future<int?> forwardMultiple({
    required String dialogId,
    required String? text,
    required List<int> forwardMessageIds,
  }) =>
      _sendMessage(
        dialogId: dialogId,
        text: text,
        forwardMessageIds: forwardMessageIds,
      );

  Future<int?> _sendMessage({
    required String dialogId,
    required String? text,
    int? replyMessageId,
    List<int>? forwardMessageIds,
  }) async {
    Response response;
    final data = <String, dynamic>{
      _DataKeys.dialogId: dialogId,
      _DataKeys.templateId: const Uuid().v4(),
      if (text != null) _DataKeys.message: text,
      if (replyMessageId != null) _DataKeys.replyId: replyMessageId.toString(),
    };

    forwardMessageIds?.forEach(
      (id) => data[_DataKeys.forwardId] = id.toString(),
    );

    try {
      response = await _apiHelper.post(
        path: ApiPath.ajax,
        queryParameters: {
          AjaxActionStrings.actionKey: AjaxActionStrings.sendMessage,
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

    if (!ResponseStatusValidator.validate(response.data, _loggerService)) {
      return null;
    }

    return response.data[_JsonKeys.data][_JsonKeys.id];
  }
}
