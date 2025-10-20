// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:collection';

import 'package:unn_mobile/core/providers/interfaces/common/message_ignored_keys_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class _MessageIgnoredKeysProviderKeys {
  static const String ignoredMessagesKey = 'ignored_messages';
}

class MessageIgnoredKeysProviderImpl implements MessageIgnoredKeysProvider {
  final StorageService _storage;

  MessageIgnoredKeysProviderImpl(this._storage);
  @override
  Future<Set<String>> getData() async {
    if (!await isContained()) {
      return HashSet();
    }

    final storedData = await _storage.read(
      key: _MessageIgnoredKeysProviderKeys.ignoredMessagesKey,
    );

    return HashSet.from(storedData?.split(';') ?? []);
  }

  @override
  Future<bool> isContained() async => _storage.containsKey(
        key: _MessageIgnoredKeysProviderKeys.ignoredMessagesKey,
      );

  @override
  Future<void> saveData(Set<String> data) async => _storage.write(
        key: _MessageIgnoredKeysProviderKeys.ignoredMessagesKey,
        value: data.join(';'),
      );

  @override
  Future<void> removeData() async =>
      _storage.remove(key: _MessageIgnoredKeysProviderKeys.ignoredMessagesKey);
}
