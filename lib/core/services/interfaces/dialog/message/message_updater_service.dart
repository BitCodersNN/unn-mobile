abstract interface class MessageUpdaterService {
  Future<bool> update({
    required int messageId,
    required String text,
  });
}
