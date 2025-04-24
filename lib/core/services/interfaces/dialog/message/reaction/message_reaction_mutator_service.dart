// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/feed/rating_list.dart';

abstract interface class MessageReactionMutatorService {
  /// Добавляет реакцию к указанному сообщению.
  ///
  /// Параметры:
  ///   - [messageId] - идентификатор сообщения, к которому добавляется реакция
  ///   - [reactionType] - тип добавляемой реакции (из перечисления ReactionType)
  ///
  /// Возвращает:
  ///   - `true` - если реакция была успешно добавлена
  ///   - `false` - если произошла ошибка при выполнении запроса
  Future<bool> addReaction(
    int messageId,
    ReactionType reactionType,
  );

  /// Удаляет реакцию с указанного сообщения.
  ///
  /// Параметры:
  ///   - [messageId] - идентификатор сообщения, с которого удаляется реакция
  ///   - [reactionType] - тип удаляемой реакции (из перечисления ReactionType)
  ///
  /// Возвращает:
  ///   - `true` - если реакция была успешно удалена
  ///   - `false` - если произошла ошибка при выполнении запроса
  Future<bool> removeReaction(
    int messageId,
    ReactionType reactionType,
  );
}
