abstract interface class MessageRemoverService {
  /// Удаляет указанное сообщение.
  ///
  /// Параметры:
  ///   - [messageId] - идентификатор удаляемого сообщения (обязательный)
  ///
  /// Возвращает:
  ///   - `true` - если сообщение было успешно удалено
  ///   - `false` - в случае ошибки или невалидного ответа сервера
  Future<bool> remove({
    required int messageId,
  });
}
