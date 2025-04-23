// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

abstract interface class MessageSenderService {
  /// Отправляет текстовое сообщение в указанный диалог.
  ///
  /// Параметры:
  ///   - [dialogId] - идентификатор диалога, в который отправляется сообщение
  ///   - [text] - текст отправляемого сообщения
  ///
  /// Возвращает:
  ///   - Идентификатор отправленного сообщения (int) в случае успешной отправки
  ///   - `null` в случае возникновения ошибки или неуспешного статуса ответа
  Future<int?> send({
    required String dialogId,
    required String text,
  });
}
