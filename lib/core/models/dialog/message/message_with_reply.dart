// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/dialog/message/message.dart';
import 'package:unn_mobile/core/models/dialog/message/message_short_info.dart';
import 'package:unn_mobile/core/models/dialog/message/reply_info.dart';

class MessageWithReply extends Message {
  final ReplyInfo replyMessage;

  MessageWithReply({
    required Message message,
    required this.replyMessage,
  }) : super(
          messageShortInfo: MessageShortInfo(
            messageId: message.messageId,
            author: message.author,
            text: message.text,
            uuid: message.uuid,
            dateTime: message.dateTime,
          ),
          ratingList: message.ratingList,
          messageStatus: message.messageStatus,
          files: message.files,
          viewedByOthers: message.viewedByOthers,
          notify: message.notify,
        );

  factory MessageWithReply.fromJson(Map<String, dynamic> jsonMap) =>
      MessageWithReply(
        message: Message.fromJson(jsonMap),
        replyMessage: ReplyInfo.fromJson(jsonMap),
      );

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ...replyMessage.toJson(),
      };
}
