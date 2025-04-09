import 'package:unn_mobile/core/models/dialog/message/forward_info.dart';
import 'package:unn_mobile/core/models/dialog/message/message.dart';
import 'package:unn_mobile/core/models/dialog/message/reply_info.dart';

class MessageWithForwardAndReply extends Message {
  final ForwardInfo forwardInfo;
  final ReplyInfo replyMessage;

  MessageWithForwardAndReply({
    required Message message,
    required this.forwardInfo,
    required this.replyMessage,
  }) : super(
          messageShortInfo: message,
          ratingList: message.ratingList,
          messageStatus: message.messageStatus,
          viewedByOthers: message.viewedByOthers,
          notify: message.notify,
        );

  factory MessageWithForwardAndReply.fromJson(Map<String, dynamic> jsonMap) =>
      MessageWithForwardAndReply(
        message: Message.fromJson(jsonMap),
        forwardInfo: ForwardInfo.fromJson(jsonMap),
        replyMessage: ReplyInfo.fromJson(jsonMap),
      );

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'forward_info': forwardInfo.toJson(),
        'reply_message': replyMessage.toJson(),
      };
}
