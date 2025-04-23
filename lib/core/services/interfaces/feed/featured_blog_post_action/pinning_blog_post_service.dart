// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

abstract interface class PinningBlogPostService {
  /// Позволяет закрепить пост с указанным идентификатором.
  ///
  /// [pinnedId] - идентификатор поста, который необходимо закрепить.
  /// Возвращает `true`, если операция прошла успешно, и `false` в случае ошибки.
  Future<bool> pin(int pinnedId);

  /// Позволяет открепить пост с указанным идентификатором.
  ///
  /// [pinnedId] - идентификатор поста, который необходимо открепить.
  /// Возвращает `true`, если операция прошла успешно, и `false` в случае ошибки.
  Future<bool> unpin(int pinnedId);
}
