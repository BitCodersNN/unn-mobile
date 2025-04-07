import 'package:unn_mobile/core/models/dialog/message/message_with_pagination.dart';

abstract interface class MessageFetcherService {
  Future<MessageWithPagination?> fetch({
    required int chatId,
    int limit,
    int? lastMessageId,
  });
}
