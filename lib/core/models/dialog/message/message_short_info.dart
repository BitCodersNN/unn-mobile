// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class MessageShortInfoJsonKeys {
  static const String id = 'id';
  static const String author = 'author';
  static const String text = 'text';
  static const String uuid = 'uuid';
  static const String date = 'date';
}

class MessageShortInfo {
  final int messageId;
  final UserShortInfo? author;
  final String text;
  final String? uuid;
  final DateTime dateTime;

  MessageShortInfo({
    required this.messageId,
    required this.author,
    required this.text,
    required this.uuid,
    required this.dateTime,
  });

  factory MessageShortInfo.fromJson(Map<String, dynamic> jsonMap) =>
      MessageShortInfo(
        messageId: jsonMap[MessageShortInfoJsonKeys.id],
        author: jsonMap[MessageShortInfoJsonKeys.author] != null
            ? UserShortInfo.fromMessageJson(
                jsonMap[MessageShortInfoJsonKeys.author],
              )
            : null,
        text: jsonMap[MessageShortInfoJsonKeys.text],
        uuid: jsonMap[MessageShortInfoJsonKeys.uuid],
        dateTime: DateTime.parse(jsonMap[MessageShortInfoJsonKeys.date]),
      );

  Map<String, dynamic> toJson() => {
        MessageShortInfoJsonKeys.id: messageId,
        if (author != null)
          MessageShortInfoJsonKeys.author: author!.toMessageJson(),
        MessageShortInfoJsonKeys.text: text,
        MessageShortInfoJsonKeys.uuid: uuid,
        MessageShortInfoJsonKeys.date: dateTime.toIso8601String(),
      };
}
