// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/dialog/message/enum/message_state.dart';
import 'package:unn_mobile/core/models/dialog/message/message_short_info.dart';

class ReplyInfoJsonKeys {
  static const String replyMessage = 'replyMessage';
  static const String replyMessageStatus = 'replyMessageStatus';
}

class ReplyInfo {
  final MessageShortInfo replyMessage;
  final MessageState messageStatus;

  ReplyInfo({
    required this.replyMessage,
    required this.messageStatus,
  });

  factory ReplyInfo.fromJson(Map<String, dynamic> jsonMap) => ReplyInfo(
        replyMessage:
            MessageShortInfo.fromJson(jsonMap[ReplyInfoJsonKeys.replyMessage]),
        messageStatus: jsonMap[ReplyInfoJsonKeys.replyMessageStatus],
      );

  Map<String, dynamic> toJson() => {
        ReplyInfoJsonKeys.replyMessage: replyMessage.toJson(),
      };
}
