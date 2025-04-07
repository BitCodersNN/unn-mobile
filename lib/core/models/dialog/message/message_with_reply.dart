import 'package:unn_mobile/core/models/dialog/message/message.dart';

class MessageWithReply extends Message {
  final Message replyMessage;

  MessageWithReply({
    required Message message,
    required this.replyMessage,
  }) : super(
          messageId: message.messageId,
          author: message.author,
          ratingList: message.ratingList,
          file: message.file,
          text: message.text,
          uuid: message.uuid,
          messageStatus: message.messageStatus,
          viewedByOthers: message.viewedByOthers,
          notify: message.notify,
        );

  factory MessageWithReply.fromJson(Map<String, dynamic> jsonMap) {
    return MessageWithReply(
      message: Message.fromJson(jsonMap),
      replyMessage: Message.fromJson(jsonMap['replyMessage']),
    );
  }
}
