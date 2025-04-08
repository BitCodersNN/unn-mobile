import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/ajax_action.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/user/user_id_mapping.dart';
import 'package:unn_mobile/core/models/dialog/message/message.dart';
import 'package:unn_mobile/core/models/dialog/message/message_status.dart';
import 'package:unn_mobile/core/models/dialog/message/message_with_forward.dart';
import 'package:unn_mobile/core/models/dialog/message/message_with_forward_and_reply.dart';
import 'package:unn_mobile/core/models/dialog/message/message_with_pagination.dart';
import 'package:unn_mobile/core/models/dialog/message/message_with_reply.dart';
import 'package:unn_mobile/core/services/implementations/dialog/message/message_reaction_service_impl.dart';
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
  final MessageReactionServiceImpl _messageReactionServiceImpl;
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  MessageFetcherServiceImpl(
    this._messageReactionServiceImpl,
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<MessageWithPagination?> fetch({
    required int chatId,
    int limit = 25,
    int? lastMessageId,
  }) async {
    final response = lastMessageId == null
        ? await _fetchFirstMessages(chatId, limit)
        : await _fetchMessages(chatId, lastMessageId, limit);

    if (response == null) return null;

    final data = response.data['data'] as Map<String, dynamic>;
    final messagesJson = data['messages'] as List;
    final usersJson = data['users'] as List;
    final filesJson = data['files'] as List;

    final usersById = buildObjectByIdrMap(usersJson);
    final filesById = buildObjectByIdrMap(filesJson);
    final additionalMessages = buildObjectByIdrMap(data['additionalMessages']);

    final List<Message> messages = [];

    for (final message in messagesJson) {
      final authorId = message['author_id'];
      final params = _processMessageParams(message['params']);
      final messageStatus = _determineMessageStatus(message, params);

      final files = _processFiles(params['FILE_ID'], filesById);
      final notify = params['NOTIFY'] != 'N';

      final jsonMap = {
        'id': message['id'],
        'author': usersById[authorId],
        'ratingList': await _messageReactionServiceImpl.fetch(message['id']),
        'files': files,
        'text': message['text'],
        'uuid': message['uuid'],
        'messageStatus': messageStatus,
        'viewedByOthers': message['viewedByOthers'],
        'notify': notify,
      };

      final replyId = int.tryParse(params['REPLY_ID'] ?? '');
      final hasReply = additionalMessages.containsKey(replyId);
      final hasForward = message['forward'] != null;

      if (hasReply && hasForward) {
        jsonMap.addAll(
          _processReplyAndForward(
            additionalMessages,
            replyId,
            message,
            usersById,
            filesById,
          ),
        );
        messages.add(MessageWithForwardAndReply.fromJson(jsonMap));
      } else if (hasReply) {
        jsonMap.addAll(
          _processReply(
            additionalMessages,
            replyId,
            usersById,
            filesById,
          ),
        );
        messages.add(MessageWithReply.fromJson(jsonMap));
      } else if (hasForward) {
        jsonMap.addAll(_processForward(message, usersById));
        messages.add(MessageWithForward.fromJson(jsonMap));
      } else {
        messages.add(Message.fromJson(jsonMap));
      }
    }

    return MessageWithPagination(
      messages: messages,
      hasPrevPage: data['hasPrevPage'],
      hasNextPage: data['hasNextPage'],
    );
  }

  Map<String, dynamic> _processMessageParams(dynamic rawParams) {
    if (rawParams is List) {
      return <String, dynamic>{};
    }
    return rawParams as Map<String, dynamic>;
  }

  MessageStatus _determineMessageStatus(
      Map<String, dynamic> message, Map<String, dynamic> params) {
    if (message['isSystem']) {
      return MessageStatus.system;
    } else if ((message['replaces'] as List).isNotEmpty) {
      return MessageStatus.edited;
    } else if (params['IS_DELETED'] == 'Y') {
      return MessageStatus.deleted;
    }
    return MessageStatus.normal;
  }

  List<dynamic> _processFiles(List? rawFileIds, Map<int, dynamic> filesById) {
    final fileIds = rawFileIds ?? [];
    return fileIds.map((fileId) => filesById[int.parse(fileId)]).toList();
  }

  Map<String, dynamic> _processReplyAndForward(
    Map<int, dynamic> additionalMessages,
    int? replyId,
    Map<String, dynamic> message,
    Map<int, dynamic> usersById,
    Map<int, dynamic> filesById,
  ) {
    final replyMessage = _processReply(
      additionalMessages,
      replyId,
      usersById,
      filesById,
    );

    return {
      ...replyMessage,
      'forwardId': message['forward']['id'],
      'forwardAuthor': usersById[message['forward']['userId']],
    };
  }

  Map<String, dynamic> _processReply(
    Map<int, dynamic> additionalMessages,
    int? replyId,
    Map<int, dynamic> usersById,
    Map<int, dynamic> filesById,
  ) {
    final additionalMessagesJson =
        additionalMessages[replyId] as Map<String, dynamic>;
    final replyFiles =
        _processFiles(additionalMessagesJson['FILE_ID'], filesById);

    return {
      'replyMessage': {
        'id': additionalMessagesJson['id'],
        'author': usersById[additionalMessagesJson['author_id']],
        'files': replyFiles,
        'text': additionalMessagesJson['text'],
        'uuid': additionalMessagesJson['uuid'],
      },
    };
  }

  Map<String, dynamic> _processForward(
    Map<String, dynamic> message,
    Map<int, dynamic> usersById,
  ) {
    return {
      'forwardId': message['forward']['id'],
      'forwardAuthor': usersById[message['forward']['userId']],
    };
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
