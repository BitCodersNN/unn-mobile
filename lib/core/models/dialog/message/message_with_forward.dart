import 'package:unn_mobile/core/models/dialog/message/forward_info.dart';
import 'package:unn_mobile/core/models/dialog/message/message.dart';

class MessageWithForward extends Message {
  final ForwardInfo forwardInfo;

  MessageWithForward({
    required Message message,
    required this.forwardInfo,
  }) : super(
          messageShortInfo: message,
          ratingList: message.ratingList,
          messageStatus: message.messageStatus,
          files: message.files,
          viewedByOthers: message.viewedByOthers,
          notify: message.notify,
        );

  factory MessageWithForward.fromJson(Map<String, dynamic> jsonMap) =>
      MessageWithForward(
        message: Message.fromJson(jsonMap),
        forwardInfo: ForwardInfo.fromJson(jsonMap),
      );

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ...forwardInfo.toJson(),
      };
}
