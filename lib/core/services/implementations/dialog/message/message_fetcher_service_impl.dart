// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/ajax_action.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/misc/object_by_id_map.dart';
import 'package:unn_mobile/core/misc/response_status_validator.dart';
import 'package:unn_mobile/core/models/dialog/message/forward_info.dart';
import 'package:unn_mobile/core/models/dialog/message/message.dart';
import 'package:unn_mobile/core/models/dialog/message/message_short_info.dart';
import 'package:unn_mobile/core/models/dialog/message/enum/message_state.dart';
import 'package:unn_mobile/core/models/dialog/message/message_with_forward.dart';
import 'package:unn_mobile/core/models/dialog/message/message_with_forward_and_reply.dart';
import 'package:unn_mobile/core/misc/objects_with_pagination.dart';
import 'package:unn_mobile/core/models/dialog/message/message_with_reply.dart';
import 'package:unn_mobile/core/models/dialog/message/reply_info.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_fetcher_service.dart';
import 'package:unn_mobile/core/aggregators/intefaces/message_reaction_service_aggregator.dart';

class _DataKeys {
  static const String chatId = 'chatId';
  static const String limit = 'limit';
  static const String lastId = 'filter[lastId]';
  static const String orderId = 'order[id]';
}

class _DataValue {
  static const String orderId = 'DESC';
}

class _JsonKeys {
  static const String data = 'data';
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
  Future<PaginatedResult?> fetch({
    required int chatId,
    int limit = 25,
    int? lastMessageId,
  }) async {
    final response = lastMessageId == null
        ? await _fetchFirstMessages(chatId, limit)
        : await _fetchMessages(chatId, lastMessageId, limit);

    if (response == null) return null;
    if (!ResponseStatusValidator.validate(response.data, _loggerService)) {
      return null;
    }

    final data = response.data[_JsonKeys.data] as Map<String, dynamic>;
    final messages = await _processMessagesData(data);

    return PaginatedResult(
      items: messages,
      hasPreviousPage: data[PaginatedResultJsonKeys.hasPrevPage],
      hasNextPage: data[PaginatedResultJsonKeys.hasNextPage],
    );
  }

  Future<List<Message>> _processMessagesData(Map<String, dynamic> data) async {
    final messagesJson = data[_JsonKeys.messages] as List;
    final usersJson = data[_JsonKeys.users] as List;
    final filesJson = data[MessageJsonKeys.files] as List;
    final reactionsJson = data[_JsonKeys.reactions] as List;

    final usersById = buildObjectByIdMap(usersJson);
    final filesById = buildObjectByIdMap(filesJson);
    final additionalMessagesById = buildObjectByIdMap(
      data[_JsonKeys.additionalMessages],
    );
    final messageIdsWithReactions = reactionsJson
        .map<int>((msg) => msg[_JsonKeys.messageId] as int)
        .toSet();

    return await parseJsonIterableAsync<Message>(
      messagesJson,
      (message) async => await _processSingleMessage(
        message,
        usersById,
        filesById,
        additionalMessagesById,
        messageIdsWithReactions,
      ),
      _loggerService,
    );
  }

  Future<Message> _processSingleMessage(
    Map<String, dynamic> message,
    Map<int, dynamic> usersById,
    Map<int, dynamic> filesById,
    Map<int, dynamic> additionalMessagesById,
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
    final hasReply = additionalMessagesById.containsKey(replyId);
    final hasForward = message[_JsonKeys.forward] != null;

    if (hasReply && hasForward) {
      final processedData = _processReplyAndForward(
        additionalMessagesById,
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
        additionalMessagesById,
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
    return fileIds.map((fileId) => filesById[int.parse(fileId)]).toList();
  }

  Map<String, dynamic> _processReplyAndForward(
    Map<int, dynamic> additionalMessagesById,
    int? replyId,
    Map<String, dynamic> message,
    Map<int, dynamic> usersById,
    Map<int, dynamic> filesById,
  ) =>
      {
        ..._processReply(
          additionalMessagesById,
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
    Map<int, dynamic> additionalMessagesById,
    int? replyId,
    Map<int, dynamic> usersById,
    Map<int, dynamic> filesById,
  ) {
    final additionalMessagesJson =
        additionalMessagesById[replyId] as Map<String, dynamic>;

    return {
      ReplyInfoJsonKeys.replyMessage: _proccessMessageShortInfo(
        additionalMessagesJson,
        usersById,
      ),
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
        ForwardInfoJsonKeys.forwardId: message[_JsonKeys.forward]
            [MessageShortInfoJsonKeys.id],
        ForwardInfoJsonKeys.forwardAuthor:
            usersById[message[_JsonKeys.forward][_JsonKeys.userId]],
      };

  Future<Response?> _fetchFirstMessages(
    int chatId,
    int limit,
  ) async =>
      _fetchMessagesFromApi(
        action: AjaxActionStrings.fetchFirstMessage,
        data: {
          _DataKeys.chatId: chatId,
          _DataKeys.limit: limit,
        },
      );

  Future<Response?> _fetchMessages(
    int chatId,
    int lastMessageId,
    int limit,
  ) async =>
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
