import 'package:unn_mobile/core/models/dialog/message/message.dart';
import 'package:unn_mobile/core/models/dialog/message/message_short_info.dart';
import 'package:unn_mobile/core/models/dialog/message/message_status.dart';

abstract class Dialog {
  final int chatId;
  final String title;
  final MessageShortInfo previewMessage;
  final MessageStatus lastMessageStatus;
  final List<Message> messages = [];
  final bool pinned;

  Dialog({
    required this.chatId,
    required this.title,
    required this.previewMessage,
    required this.lastMessageStatus,
    required this.pinned,
  });
}
