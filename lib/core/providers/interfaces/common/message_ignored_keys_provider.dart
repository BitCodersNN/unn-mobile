// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/providers/interfaces/data_provider.dart';

abstract interface class MessageIgnoredKeysProvider
    implements DataProvider<Set<String>> {
  /// Получает множество строковых ключей сообщений.
  /// Наличие ключа в множестве означает, что это сообщение не должно показываться
  @override
  Future<Set<String>> getData();

  /// Проверяет наличие множества ключей сообщений в хранилище
  @override
  Future<bool> isContained();

  /// Сохраняет множество строковых ключей сообщений в хранилище
  @override
  Future<void> saveData(Set<String> data);
}
