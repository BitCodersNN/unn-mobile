// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

abstract interface class MessageUpdaterService {
  /// Обновляет текст существующего сообщения.
  ///
  /// Параметры:
  ///   - [messageId] - идентификатор обновляемого сообщения (обязательный)
  ///   - [text] - новый текст сообщения (обязательный)
  ///
  /// Возвращает:
  ///   - `true` - если сообщение было успешно обновлено
  ///   - `false` - в случае ошибки или невалидного ответа сервера
  Future<bool> update({
    required int messageId,
    required String text,
  });
}
