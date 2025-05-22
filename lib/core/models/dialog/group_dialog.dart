// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

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

final class GroupDialog extends Dialog {
  final String id;
  final ChatSetting chatSetting;

  GroupDialog({
    required super.chatId,
    required super.title,
    required super.avatarUrl,
    required super.previewMessage,
    required super.unreadMessagesCount,
    required super.lastMessageStatus,
    required super.pinned,
    required this.id,
    required this.chatSetting,
  });

  factory GroupDialog.fromJson(Map<String, dynamic> json) {
    final dialog = Dialog.fromJson(json);

    return GroupDialog(
      chatId: dialog.chatId,
      title: dialog.title,
      avatarUrl: dialog.avatarUrl,
      previewMessage: dialog.previewMessage,
      unreadMessagesCount: dialog.unreadMessagesCount,
      lastMessageStatus: dialog.lastMessageStatus,
      pinned: dialog.pinned,
      id: json[GroupDialogJsonKeys.id],
      chatSetting: _parseChatSetting(json[GroupDialogJsonKeys.chat]),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      GroupDialogJsonKeys.id: id,
      GroupDialogJsonKeys.chat: chatSetting.toJson(),
      GroupDialogJsonKeys.type: 'chat',
    };
  }

  static ChatSetting _parseChatSetting(Map<String, dynamic> chatJson) {
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
