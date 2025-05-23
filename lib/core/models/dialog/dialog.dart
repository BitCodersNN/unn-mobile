// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/enum_from_string.dart';
import 'package:unn_mobile/core/models/dialog/enum/message_status.dart';
import 'package:unn_mobile/core/models/dialog/message/message_short_info.dart';

class _DialogJsonKeys {
  static const String chatId = 'chat_id';
  static const String title = 'title';
  static const String avatar = 'avatar';
  static const String url = 'url';
  static const String message = 'message';
  static const String user = 'user';
  static const String pinned = 'pinned';
  static const String file = 'file';
  static const String name = 'name';
  static const String text = 'text';
  static const String status = 'status';
  static const String counter = 'counter';
}

base class Dialog {
  final int chatId;
  final String title;
  final String avatarUrl;
  final MessageShortInfo previewMessage;
  final MessageStatus lastMessageStatus;
  final int unreadMessagesCount;
  final bool pinned;

  String get formatUnreadCount {
    if (unreadMessagesCount < 1000) return '$unreadMessagesCount';
    return '${(unreadMessagesCount / 1000.0).toStringAsFixed(1)}k';
  }

  Dialog({
    required this.chatId,
    required this.title,
    required this.avatarUrl,
    required this.previewMessage,
    required this.lastMessageStatus,
    required this.unreadMessagesCount,
    required this.pinned,
  });

  factory Dialog.fromJson(Map<String, dynamic> jsonMap) {
    final messageMap = jsonMap[_DialogJsonKeys.message];
    final fileInfo = messageMap[_DialogJsonKeys.file];

    if (fileInfo != null && fileInfo != false) {
      final fileName = fileInfo[_DialogJsonKeys.name].toString();
      messageMap[_DialogJsonKeys.text] = 'Файл: $fileName';
    }
    return Dialog(
      chatId: jsonMap[_DialogJsonKeys.chatId],
      title: jsonMap[_DialogJsonKeys.title],
      avatarUrl: jsonMap[_DialogJsonKeys.avatar][_DialogJsonKeys.url],
      previewMessage: MessageShortInfo.fromJson({
        ...messageMap,
        MessageShortInfoJsonKeys.author: jsonMap[_DialogJsonKeys.user],
      }),
      lastMessageStatus: enumFromString<MessageStatus>(
        MessageStatus.values,
        messageMap[_DialogJsonKeys.status],
      ),
      unreadMessagesCount: jsonMap[_DialogJsonKeys.counter],
      pinned: jsonMap[_DialogJsonKeys.pinned],
    );
  }

  Map<String, dynamic> toJson() {
    final messageMap = previewMessage.toJson();

    return {
      _DialogJsonKeys.chatId: chatId,
      _DialogJsonKeys.title: title,
      _DialogJsonKeys.avatar: {
        _DialogJsonKeys.url: avatarUrl,
      },
      _DialogJsonKeys.message: {
        ...messageMap,
        _DialogJsonKeys.status: lastMessageStatus.toString().split('.').last,
      },
      _DialogJsonKeys.counter: unreadMessagesCount,
      _DialogJsonKeys.user: messageMap[MessageShortInfoJsonKeys.author],
      _DialogJsonKeys.pinned: pinned,
    };
  }
}
