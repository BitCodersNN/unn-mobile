part of '../library.dart';

abstract interface class ReactionManager {
  /// Добавление реакции
  ///
  /// [ReactionType] reactionType: тип реакции
  /// [String] voteKeySigned: bitrix
  ///
  /// Возвращает [ReactionUserInfo] или null, если:
  ///   1. Не вышло получить ответ от портала
  ///   2. statusCode не равен 200
  ///   3. Не вышло декодировать ответ
  Future<ReactionUserInfo?> addReaction(
    ReactionType reactionType,
    String voteKeySigned,
  );

  /// Удаление реакции
  ///
  /// [String] voteKeySigned: bitrix
  ///
  /// Возвращает [bool]
  /// false:
  ///   1. Не вышло получить ответ от портала
  ///   2. statusCode не равен 200
  ///   3. Не вышло декодировать ответ
  ///   4. Реакции и так не было
  /// true:
  ///   в остальных случаях
  Future<bool> removeReaction(
    String voteKeySigned,
  );
}
