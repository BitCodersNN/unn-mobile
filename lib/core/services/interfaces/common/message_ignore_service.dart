// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:core';

abstract interface class MessageIgnoreService {
  /// Добавляет строковой ключ к множеству ключей игнорируемых сообщений.
  /// [key] - значение ключа
  Future<void> addIgnoreMessageKey(String key);

  /// Проверяет наличие строкового ключа сообщения в множестве игнорируемых.
  /// Возвращает true, если ключ содержится в множестве. В такой ситуации
  /// сообщение, имеющее данный ключ, не должно показываться пользователю.
  /// Ключ [key] может содержать латинские буквы (прописные и строчные), цифры
  /// и символ нижнего подчёркивания (_), остальные символы будут превращены в _
  Future<bool> isMessageIgnored(String key);
}
