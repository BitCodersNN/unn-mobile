// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

abstract class BaseDialogInfo {
  final int chatId;
  final String title;
  final String avatarUrl;

  BaseDialogInfo({
    required this.chatId,
    required this.title,
    required this.avatarUrl,
  });
}
