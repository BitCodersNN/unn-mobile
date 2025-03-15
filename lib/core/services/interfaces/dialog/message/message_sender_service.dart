abstract interface class MessageSenderService {
  Future<int?> send({
    required String dialogId,
    required String text,
  });
}
