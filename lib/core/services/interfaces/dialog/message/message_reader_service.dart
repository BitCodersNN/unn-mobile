// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

abstract interface class MessageReaderService {
  Future<bool> readMessage({
    required int chatId,
    required int messageId,
  });

  Future<bool> readMessages({
    required int chatId,
    required Iterable<int> messageIds,
  });
}
