// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/providers/interfaces/common/message_ignored_keys_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/message_ignore_service.dart';

class MessageIgnoreServiceImpl implements MessageIgnoreService {
  final MessageIgnoredKeysProvider _messageIgnoredKeysProvider;

  MessageIgnoreServiceImpl(this._messageIgnoredKeysProvider);
  @override
  Future<void> addIgnoreMessageKey(String key) async {
    final sanitizedKey = _sanitizeKey(key);
    final keys = await _messageIgnoredKeysProvider.getData();

    if (keys.contains(sanitizedKey)) {
      return;
    }

    keys.add(sanitizedKey);
    _messageIgnoredKeysProvider.saveData(keys);
  }

  @override
  Future<bool> isMessageIgnored(String key) async {
    final sanitizedKey = _sanitizeKey(key);
    final keys = await _messageIgnoredKeysProvider.getData();

    return keys.contains(sanitizedKey);
  }

  String _sanitizeKey(String key) {
    return key.replaceAllMapped(RegExp(r'[^a-zA-Z0-9_]'), (_) => '_');
  }
}
