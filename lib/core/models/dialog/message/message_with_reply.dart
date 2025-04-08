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
            file: message.file,
            text: message.text,
            uuid: message.uuid,
          ),
          ratingList: message.ratingList,
          messageStatus: message.messageStatus,
          viewedByOthers: message.viewedByOthers,
          notify: message.notify,
        );

  factory MessageWithReply.fromJson(Map<String, dynamic> jsonMap) =>
      MessageWithReply(
        message: Message.fromJson(jsonMap),
        replyMessage: ReplyInfo.fromJson(jsonMap),
      );
}
