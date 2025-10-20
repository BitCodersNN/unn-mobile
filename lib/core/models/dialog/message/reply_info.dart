// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
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

  factory ReplyInfo.fromJson(JsonMap jsonMap) => ReplyInfo(
        replyMessage: MessageShortInfo.fromJson(
          jsonMap[ReplyInfoJsonKeys.replyMessage]! as JsonMap,
        ),
        messageStatus:
            jsonMap[ReplyInfoJsonKeys.replyMessageStatus]! as MessageState,
      );

  JsonMap toJson() => {
        ReplyInfoJsonKeys.replyMessage: replyMessage.toJson(),
      };
}
