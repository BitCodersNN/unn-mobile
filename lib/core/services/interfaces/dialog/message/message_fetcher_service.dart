import 'package:unn_mobile/core/misc/objects_with_pagination.dart';

abstract interface class MessageFetcherService {
  Future<PaginatedResult?> fetch({
    required int chatId,
    int limit,
    int? lastMessageId,
  });
}
