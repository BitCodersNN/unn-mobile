// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/dialog/chat_settings/calendar_chat_setting.dart';
import 'package:unn_mobile/core/models/dialog/chat_settings/chat_setting.dart';
import 'package:unn_mobile/core/models/dialog/chat_settings/sonnet_group_chat_setting.dart';
import 'package:unn_mobile/core/models/dialog/dialog.dart';

class GroupDialogJsonKeys {
  static const String id = 'id';
  static const String chat = 'chat';
  static const String type = 'type';
  static const String calendar = 'calendar';
  static const String sonetGroup = 'sonetGroup';
}

final class GroupDialog extends Dialog<String> {
  final ChatSetting chatSetting;

  GroupDialog({
    required super.dialogId,
    required super.chatId,
    required super.title,
    required super.avatarUrl,
    required super.previewMessage,
    required super.unreadMessagesCount,
    required super.lastMessageStatus,
    required super.pinned,
    required this.chatSetting,
  });

  factory GroupDialog.fromJson(JsonMap json) {
    final dialog = Dialog<String>.fromJson(json);

    return GroupDialog(
      title: dialog.title,
      avatarUrl: dialog.avatarUrl,
      previewMessage: dialog.previewMessage,
      unreadMessagesCount: dialog.unreadMessagesCount,
      lastMessageStatus: dialog.lastMessageStatus,
      pinned: dialog.pinned,
      chatId: dialog.chatId,
      dialogId: json[GroupDialogJsonKeys.id]! as String,
      chatSetting:
          _parseChatSetting(json[GroupDialogJsonKeys.chat]! as JsonMap),
    );
  }

  @override
  JsonMap toJson() => {
        ...super.toJson(),
        GroupDialogJsonKeys.chat: chatSetting.toJson(),
        GroupDialogJsonKeys.type: GroupDialogJsonKeys.chat,
      };

  static ChatSetting _parseChatSetting(JsonMap chatJson) {
    final type = chatJson[GroupDialogJsonKeys.type] as String?;

    switch (type) {
      case GroupDialogJsonKeys.calendar:
        return CalendarChatSetting.fromJson(chatJson);
      case GroupDialogJsonKeys.sonetGroup:
        return SonnetGroupChatSetting.fromJson(chatJson);
      default:
        return ChatSetting.fromJson(chatJson);
    }
  }
}
