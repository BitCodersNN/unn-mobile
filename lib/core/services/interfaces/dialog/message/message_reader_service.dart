abstract interface class MessageReaderService {
  Future<bool> readMessage({
    required int chatId,
    required int messageId,
  });

  Future<bool> readMessages({
    required int chatId,
    required List<int> messageIds,
  });
}
