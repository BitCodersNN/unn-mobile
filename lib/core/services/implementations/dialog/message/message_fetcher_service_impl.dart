// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/aggregators/interfaces/message_reaction_service_aggregator.dart';
import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/constants/api/ajax_action.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/misc/object_by_id_map.dart';
import 'package:unn_mobile/core/misc/objects_with_pagination.dart';
import 'package:unn_mobile/core/misc/response_status_validator.dart';
import 'package:unn_mobile/core/models/dialog/message/enum/message_state.dart';
import 'package:unn_mobile/core/models/dialog/message/forward_info.dart';
import 'package:unn_mobile/core/models/dialog/message/message.dart';
import 'package:unn_mobile/core/models/dialog/message/message_short_info.dart';
import 'package:unn_mobile/core/models/dialog/message/message_with_forward.dart';
import 'package:unn_mobile/core/models/dialog/message/message_with_forward_and_reply.dart';
import 'package:unn_mobile/core/models/dialog/message/message_with_reply.dart';
import 'package:unn_mobile/core/models/dialog/message/reply_info.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_fetcher_service.dart';

class _DataKeys {
  static const String chatId = 'chatId';
  static const String dialogId = 'dialogId';
  static const String limit = 'limit';
  static const String messageLimit = 'messageLimit';
  static const String lastId = 'filter[lastId]';
  static const String orderId = 'order[id]';
}

class _DataValue {
  static const String orderId = 'DESC';
}

class _JsonKeys {
  static const String data = 'data';
  static const String chat = 'chat';
  static const String id = 'id';
  static const String messages = 'messages';
  static const String messageId = 'messageId';
  static const String reactions = 'reactions';
  static const String users = 'users';
  static const String additionalMessages = 'additionalMessages';
  static const String params = 'params';
  static const String fileId = 'FILE_ID';
  static const String notify = 'NOTIFY';
  static const String replyId = 'REPLY_ID';
  static const String forward = 'forward';
  static const String isSystem = 'isSystem';
  static const String isDeleted = 'IS_DELETED';
  static const String replaces = 'replaces';
  static const String authorId = 'author_id';
  static const String userId = 'userId';
}

class MessageFetcherServiceImpl implements MessageFetcherService {
  final MessageReactionServiceAggregator _reactionServiceAggregator;
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  MessageFetcherServiceImpl(
    this._reactionServiceAggregator,
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<PaginatedResult<Message>?> fetchByChatId({
    required int chatId,
    int limit = 25,
    int? lastMessageId,
  }) async =>
      _processPaginatedResponse<PaginatedResult<Message>>(
        lastMessageId == null
            ? await _fetchFirstMessages(chatId, limit)
            : await _fetchMessages(chatId, lastMessageId, limit),
        (data, messages) => PaginatedResult(
          items: messages,
          hasPreviousPage:
              data[PaginatedResultJsonKeys.hasPrevPage] as bool? ?? false,
          hasNextPage: data[PaginatedResultJsonKeys.hasNextPage]! as bool,
        ),
      );

  @override
  Future<PaginatedResultWithChatId<Message>?> fetchByDialogId({
    required String dialogId,
    int limit = 25,
  }) async =>
      _processPaginatedResponse<PaginatedResultWithChatId<Message>>(
        await _fetchFirstMessages(dialogId, limit, false),
        (data, messages) => PaginatedResultWithChatId(
          chatId: (data[_JsonKeys.chat]! as JsonMap)[_JsonKeys.id]! as int,
          items: messages,
          hasPreviousPage:
              data[PaginatedResultJsonKeys.hasPrevPage] as bool? ?? false,
          hasNextPage: data[PaginatedResultJsonKeys.hasNextPage]! as bool,
        ),
      );

  Future<T?> _processPaginatedResponse<T>(
    Response? response,
    T Function(JsonMap data, List<Message> messages) createResult,
  ) async {
    if (response == null) {
      return null;
    }
    if (!ResponseStatusValidator.validate(response.data, _loggerService)) {
      return null;
    }

    final data = (response.data as JsonMap)[_JsonKeys.data]! as JsonMap;
    final messages = await _processMessagesData(data);

    return createResult(data, messages);
  }

  Future<List<Message>> _processMessagesData(Map<String, dynamic> data) {
    final messagesJson = data[_JsonKeys.messages] as List;
    final usersJson = data[_JsonKeys.users] as List;
    final filesJson = data[MessageJsonKeys.files] as List;
    final reactionsJson = data[_JsonKeys.reactions] as List;

    final usersById = buildObjectByIdMap(usersJson);
    final filesById = buildObjectByIdMap(filesJson);
    final messagesById = {
      ...buildObjectByIdMap(data[_JsonKeys.additionalMessages]),
      ...buildObjectByIdMap(data[_JsonKeys.messages]),
    };
    final messageIdsWithReactions = {
      for (final msg in reactionsJson)
        (msg as JsonMap)[_JsonKeys.messageId]! as int,
    };

    return parseJsonIterableAsync<Message>(
      messagesJson,
      (message) => _processSingleMessage(
        message,
        usersById,
        filesById,
        messagesById,
        messageIdsWithReactions,
      ),
      _loggerService,
    );
  }

  Future<Message> _processSingleMessage(
    Map<String, dynamic> message,
    Map<int, dynamic> usersById,
    Map<int, dynamic> filesById,
    Map<int, dynamic> messagesById,
    Set<int> messageIdsWithReactions,
  ) async {
    final params = _processMessageParams(message[_JsonKeys.params]);
    final messageId = message[MessageShortInfoJsonKeys.id];
    final messageStatus = _determineMessageStatus(message, params);
    final files = _processFiles(params[_JsonKeys.fileId], filesById);
    final notify = params[_JsonKeys.notify] != 'N';
    final hasReactions = messageIdsWithReactions.contains(
      messageId,
    );

    final jsonMap = {
      ..._proccessMessageShortInfo(message, usersById),
      MessageJsonKeys.messageStatus: messageStatus,
      MessageJsonKeys.files: files,
      MessageJsonKeys.viewedByOthers: message[MessageJsonKeys.viewedByOthers],
      MessageJsonKeys.notify: notify,
      MessageJsonKeys.ratingList: hasReactions
          ? await _reactionServiceAggregator.fetch(messageId)
          : RatingList(),
    };

    final replyId = int.tryParse(params[_JsonKeys.replyId] ?? '');
    final hasReply = messagesById.containsKey(replyId);
    final hasForward = message[_JsonKeys.forward] != null;

    if (hasReply && hasForward) {
      final processedData = _processReplyAndForward(
        messagesById,
        replyId,
        message,
        usersById,
        filesById,
      );
      return MessageWithForwardAndReply.fromJson(
        {...jsonMap, ...processedData},
      );
    }

    if (hasReply) {
      final processedData = _processReply(
        messagesById,
        replyId,
        usersById,
        filesById,
      );
      return MessageWithReply.fromJson({...jsonMap, ...processedData});
    }

    if (hasForward) {
      final processedData = _processForward(message, usersById);
      return MessageWithForward.fromJson({...jsonMap, ...processedData});
    }

    return Message.fromJson(jsonMap);
  }

  Map<String, dynamic> _processMessageParams(dynamic rawParams) {
    if (rawParams is List) {
      return <String, dynamic>{};
    }
    return rawParams as Map<String, dynamic>;
  }

  MessageState _determineMessageStatus(
    Map<String, dynamic> message,
    Map<String, dynamic> params,
  ) {
    if (message[_JsonKeys.isSystem] == true) {
      return MessageState.system;
    }
    if (params[_JsonKeys.isDeleted] == 'Y') {
      return MessageState.deleted;
    }
    if ((message[_JsonKeys.replaces] as List).isNotEmpty) {
      return MessageState.edited;
    }
    return MessageState.normal;
  }

  List<dynamic> _processFiles(List? rawFileIds, Map<int, dynamic> filesById) {
    final fileIds = rawFileIds ?? [];
    return [for (final fileId in fileIds) filesById[int.parse(fileId)]];
  }

  Map<String, dynamic> _processReplyAndForward(
    Map<int, dynamic> messagesById,
    int? replyId,
    Map<String, dynamic> message,
    Map<int, dynamic> usersById,
    Map<int, dynamic> filesById,
  ) =>
      {
        ..._processReply(
          messagesById,
          replyId,
          usersById,
          filesById,
        ),
        ..._processForward(
          message,
          usersById,
        ),
      };

  Map<String, dynamic> _processReply(
    Map<int, dynamic> messagesById,
    int? replyId,
    Map<int, dynamic> usersById,
    Map<int, dynamic> filesById,
  ) {
    final messagesJson = messagesById[replyId] as Map<String, dynamic>;
    final params = _processMessageParams(messagesJson[_JsonKeys.params]);
    final messageStatus = _determineMessageStatus(messagesJson, params);

    return {
      ReplyInfoJsonKeys.replyMessage: _proccessMessageShortInfo(
        messagesJson,
        usersById,
      ),
      ReplyInfoJsonKeys.replyMessageStatus: messageStatus,
    };
  }

  Map<String, dynamic> _proccessMessageShortInfo(
    Map<String, dynamic> messagesJson,
    Map<int, dynamic> usersById,
  ) =>
      {
        MessageShortInfoJsonKeys.id: messagesJson[MessageShortInfoJsonKeys.id],
        MessageShortInfoJsonKeys.author:
            usersById[messagesJson[_JsonKeys.authorId]],
        MessageShortInfoJsonKeys.text:
            messagesJson[MessageShortInfoJsonKeys.text],
        MessageShortInfoJsonKeys.uuid:
            messagesJson[MessageShortInfoJsonKeys.uuid],
        MessageShortInfoJsonKeys.date:
            messagesJson[MessageShortInfoJsonKeys.date],
      };

  Map<String, dynamic> _processForward(
    Map<String, dynamic> message,
    Map<int, dynamic> usersById,
  ) =>
      {
        ForwardInfoJsonKeys.forwardId: (message[_JsonKeys.forward]
            as JsonMap)[MessageShortInfoJsonKeys.id],
        ForwardInfoJsonKeys.forwardAuthor: usersById[
            (message[_JsonKeys.forward] as JsonMap)[_JsonKeys.userId]],
      };

  Future<Response?> _fetchFirstMessages(
    dynamic id,
    int limit, [
    bool isChatId = true,
  ]) =>
      _fetchMessagesFromApi(
        action: isChatId
            ? AjaxActionStrings.fetchFirstMessageByChatId
            : AjaxActionStrings.fetchFirstMessageByDialogId,
        data: isChatId
            ? {
                _DataKeys.chatId: id as int,
                _DataKeys.limit: limit,
              }
            : {
                _DataKeys.dialogId: id as String,
                _DataKeys.messageLimit: limit,
              },
      );

  Future<Response?> _fetchMessages(
    int chatId,
    int lastMessageId,
    int limit,
  ) =>
      _fetchMessagesFromApi(
        action: AjaxActionStrings.fetchMessage,
        data: {
          _DataKeys.chatId: chatId,
          _DataKeys.limit: limit,
          _DataKeys.lastId: lastMessageId,
          _DataKeys.orderId: _DataValue.orderId,
        },
      );

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
