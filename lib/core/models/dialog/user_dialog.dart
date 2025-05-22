// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/dialog/dialog.dart';

class _UserDialogJsonKeys {
  static const String id = 'id';
  static const String type = 'type';
}

final class UserDialog extends Dialog {
  final int id;

  UserDialog({
    required super.chatId,
    required super.title,
    required super.avatarUrl,
    required super.previewMessage,
    required super.unreadMessagesCount,
    required super.lastMessageStatus,
    required super.pinned,
    required this.id,
  });

  factory UserDialog.fromJson(Map<String, dynamic> json) {
    final dialog = Dialog.fromJson(json);
    return UserDialog(
      chatId: dialog.chatId,
      title: dialog.title,
      avatarUrl: dialog.avatarUrl,
      previewMessage: dialog.previewMessage,
      unreadMessagesCount: dialog.unreadMessagesCount,
      lastMessageStatus: dialog.lastMessageStatus,
      pinned: dialog.pinned,
      id: json[_UserDialogJsonKeys.id],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        _UserDialogJsonKeys.id: id,
        _UserDialogJsonKeys.type: 'user',
      };
}
