// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/dialog/dialog.dart';

class _UserDialogJsonKeys {
  static const String id = 'id';
  static const String type = 'type';
  static const String user = 'user';
  static const String lastActivityDate = 'last_activity_date';
}

final class UserDialog extends Dialog {
  final int dialogId;
  final DateTime? lastActivityAt;

  UserDialog({
    required super.chatId,
    required super.title,
    required super.avatarUrl,
    required super.previewMessage,
    required super.unreadMessagesCount,
    required super.lastMessageStatus,
    required super.pinned,
    required this.dialogId,
    required this.lastActivityAt,
  });

  factory UserDialog.fromJson(JsonMap json) {
    final dialog = Dialog.fromJson(json);
    return UserDialog(
      chatId: dialog.chatId,
      title: dialog.title,
      avatarUrl: dialog.avatarUrl,
      previewMessage: dialog.previewMessage,
      unreadMessagesCount: dialog.unreadMessagesCount,
      lastMessageStatus: dialog.lastMessageStatus,
      pinned: dialog.pinned,
      dialogId: json[_UserDialogJsonKeys.id]! as int,
      lastActivityAt: DateTime.tryParse(
        (json[_UserDialogJsonKeys.user]!
            as JsonMap)[_UserDialogJsonKeys.lastActivityDate]! as String,
      ),
    );
  }

  @override
  JsonMap toJson() => {
        ...super.toJson(),
        _UserDialogJsonKeys.id: dialogId,
        _UserDialogJsonKeys.type: _UserDialogJsonKeys.user,
        _UserDialogJsonKeys.user: {
          _UserDialogJsonKeys.lastActivityDate:
              lastActivityAt?.toIso8601String(),
        },
      };
}
