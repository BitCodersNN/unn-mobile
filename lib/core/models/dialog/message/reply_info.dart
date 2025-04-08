import 'package:unn_mobile/core/models/dialog/message/message_short_info.dart';

class ReplyInfo {
  final MessageShortInfo replyMessage;

  ReplyInfo({
    required this.replyMessage,
  });

  factory ReplyInfo.fromJson(Map<String, dynamic> jsonMap) => ReplyInfo(
        replyMessage: MessageShortInfo.fromJson(jsonMap['replyMessage']),
      );
}
