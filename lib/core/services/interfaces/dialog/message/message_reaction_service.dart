// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/feed/reaction_service.dart';

abstract interface class MessageReactionService implements ReactionService {
  /// Получает список реакций на сообщение с информацией о пользователях.
  ///
  /// Параметры:
  ///   - [messageId] - идентификатор сообщения, для которого запрашиваются реакции
  ///
  /// Возвращает:
  ///   - [RatingList] с информацией о реакциях и пользователях, которые их поставили
  ///   - `null` в случае возникновения ошибки
  Future<RatingList?> fetch(int messageId);
}
