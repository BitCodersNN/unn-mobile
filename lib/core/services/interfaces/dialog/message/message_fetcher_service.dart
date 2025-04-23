// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/objects_with_pagination.dart';

abstract interface class MessageFetcherService {
  /// Получает пагинированный список сообщений из чата.
  ///
  /// Параметры:
  ///   - [chatId] - идентификатор чата, из которого запрашиваются сообщения (обязательный)
  ///   - [limit] - максимальное количество сообщений в результате (по умолчанию 25)
  ///   - [lastMessageId] - идентификатор последнего сообщения для пагинации (опциональный)
  ///     * Если null - запрашивает первые сообщения чата
  ///     * Если указан - запрашивает сообщения относительно указанного ID
  ///
  /// Возвращает [PaginatedResult] с:
  ///   - Списком сообщений ([items])
  ///   - Флагами наличия предыдущей/следующей страниц ([hasPreviousPage], [hasNextPage])
  ///
  /// В случае ошибки:
  ///   - Возвращает `null`
  Future<PaginatedResult?> fetch({
    required int chatId,
    int limit,
    int? lastMessageId,
  });
}
