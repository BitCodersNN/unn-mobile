import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/ajax_action.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/user/user_id_mapping.dart';
import 'package:unn_mobile/core/models/dialog/message/message.dart';
import 'package:unn_mobile/core/models/dialog/message/message_status.dart';
import 'package:unn_mobile/core/models/dialog/message/message_with_pagination.dart';
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

    if (response == null) {
      return null;
    }

    final data = response.data['data'] as Map<String, dynamic>;
    final messagesJson = data['messages'] as List;
    final usersJson = data['users'] as List;
    final filesJson = data['files'] as List;

    final List<Message> messages = [];

    final usersById = buildObjectByIdrMap(usersJson);
    final filesById = buildObjectByIdrMap(filesJson);

    for (final message in messagesJson) {
      final authorId = message['author_id'];
      dynamic params = message['params'];
      MessageStatus messageStatus = MessageStatus.normal;
      if (params is List) {
        params = <String, dynamic>{};
      }
      if (message['isSystem']) {
        messageStatus = MessageStatus.system;
      } else if ((message['replaces'] as List).isNotEmpty) {
        messageStatus = MessageStatus.edited;
      } else if (params['IS_DELETED'] == 'Y') {
        messageStatus = MessageStatus.deleted;
      }

      final List filesJson = [];
      final fileIds = params['FILE_ID'] as List? ?? [];
       for (final fileId in fileIds) {
        filesJson.add(filesById[int.parse(fileId)]);
       }

      final notify = params['NOTIFY'] == 'N' ? false : true;

      final Map<String, dynamic> jsonMap = {
        'id': message['id'],
        'author': usersById[authorId],
        'ratingList': await _messageReactionServiceImpl.fetch(message['id']),
        'files': filesJson,
        'text': message['text'],
        'uuid': message['uuid'],
        'messageStatus': messageStatus,
        'viewedByOthers': message['viewedByOthers'],
        'notify': notify,
      };

      messages.add(Message.fromJson(jsonMap));
    }

    return MessageWithPagination(
      messages: messages,
      hasPrevPage: data['hasPrevPage'],
      hasNextPage: data['hasNextPage'],
    );
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
