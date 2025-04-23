// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/feed/rating_list.dart';

abstract interface class MessageReactionFetcherService {
  /// Получает список реакций пользователей на указанное сообщение.
  ///
  /// Параметры:
  ///   - [messageId] - идентификатор сообщения, для которого запрашиваются реакции
  ///
  /// Возвращает:
  ///   - [RatingList] с информацией о пользователях и их реакциях
  ///   - `null` в случае ошибки запроса или невалидного ответа
  Future<RatingList?> fetch(int messageId);
}
