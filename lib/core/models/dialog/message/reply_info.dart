import 'package:unn_mobile/core/models/dialog/message/message_short_info.dart';

class ReplyInfoJsonKeys {
  static const String replyMessage = 'replyMessage';
}

class ReplyInfo {
  final MessageShortInfo replyMessage;

  ReplyInfo({
    required this.replyMessage,
  });

  factory ReplyInfo.fromJson(Map<String, dynamic> jsonMap) => ReplyInfo(
        replyMessage:
            MessageShortInfo.fromJson(jsonMap[ReplyInfoJsonKeys.replyMessage]),
      );

  Map<String, dynamic> toJson() => {
        ReplyInfoJsonKeys.replyMessage: replyMessage.toJson(),
      };
}
