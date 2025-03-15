abstract interface class MessageFetcherService {
  Future<List?> fetch({
    required int chatId,
    int limit,
    int? lastMessageId,
  });
}
