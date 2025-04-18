import 'package:unn_mobile/core/misc/enum_to_string.dart';
import 'package:unn_mobile/core/models/dialog/enum/message_status.dart';
import 'package:unn_mobile/core/models/dialog/message/message_short_info.dart';

base class Dialog {
  final int chatId;
  final String title;
  final MessageShortInfo previewMessage;
  final MessageStatus lastMessageStatus;
  final bool pinned;

  Dialog({
    required this.chatId,
    required this.title,
    required this.previewMessage,
    required this.lastMessageStatus,
    required this.pinned,
  });

  factory Dialog.fromJson(Map<String, dynamic> jsonMap) {
    if (jsonMap['message']['file'] != false) {
      final fileName = jsonMap['message']['file']['name'];
      jsonMap['message']['text'] = 'Файл: $fileName';
    }
    return Dialog(
      chatId: jsonMap['chat_id'],
      title: jsonMap['title'],
      previewMessage: MessageShortInfo.fromJson({
        ...jsonMap['message'],
        MessageShortInfoJsonKeys.author: jsonMap['user'],
      }),
      lastMessageStatus: enumFromString<MessageStatus>(
        MessageStatus.values,
        jsonMap['message']['status'],
      ),
      pinned: jsonMap['pinned'],
    );
  }
}
