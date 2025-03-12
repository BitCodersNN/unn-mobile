import 'dart:core';

abstract interface class MessageIgnoreService {
  Future<void> addIgnoreMessageKey(String key);

  Future<bool> isMessageIgnored(String key);
}
