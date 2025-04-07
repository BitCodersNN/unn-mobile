import 'package:unn_mobile/core/models/dialog/message/message.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class MessageWithForward extends Message {
  final int forwardChatId;
  final UserShortInfo forwardAuthor;

  MessageWithForward({
    required Message message,
    required this.forwardChatId,
    required this.forwardAuthor,
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

  factory MessageWithForward.fromJson(Map<String, dynamic> jsonMap) {
    return MessageWithForward(
      message: Message.fromJson(jsonMap),
      forwardChatId: jsonMap['forwardChatId'],
      forwardAuthor: jsonMap['forwardAuthor'],
    );
  }
}
