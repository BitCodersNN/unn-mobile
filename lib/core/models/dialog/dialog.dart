import 'package:unn_mobile/core/misc/enum_to_string.dart';
import 'package:unn_mobile/core/models/dialog/enum/message_status.dart';
import 'package:unn_mobile/core/models/dialog/message/message_short_info.dart';

class _DialogJsonKeys {
  static const String chatId = 'chat_id';
  static const String title = 'title';
  static const String message = 'message';
  static const String user = 'user';
  static const String pinned = 'pinned';
  static const String file = 'file';
  static const String name = 'name';
  static const String text = 'text';
  static const String status = 'status';
}

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
    final messageMap = jsonMap[_DialogJsonKeys.message];
    final fileInfo = messageMap[_DialogJsonKeys.file];

    if (fileInfo != null && fileInfo != false) {
      final fileName = fileInfo[_DialogJsonKeys.name].toString();
      messageMap[_DialogJsonKeys.text] = 'Файл: $fileName';
    }
    return Dialog(
      chatId: jsonMap[_DialogJsonKeys.chatId],
      title: jsonMap[_DialogJsonKeys.title],
      previewMessage: MessageShortInfo.fromJson({
        ...messageMap,
        MessageShortInfoJsonKeys.author: jsonMap[_DialogJsonKeys.user],
      }),
      lastMessageStatus: enumFromString<MessageStatus>(
        MessageStatus.values,
        messageMap[_DialogJsonKeys.status],
      ),
      pinned: jsonMap[_DialogJsonKeys.pinned],
    );
  }

  Map<String, dynamic> toJson() {
    final messageMap = previewMessage.toJson();

    return {
      _DialogJsonKeys.chatId: chatId,
      _DialogJsonKeys.title: title,
      _DialogJsonKeys.message: {
        ...messageMap,
        _DialogJsonKeys.status: lastMessageStatus.toString().split('.').last,
      },
      _DialogJsonKeys.user: messageMap[MessageShortInfoJsonKeys.author],
      _DialogJsonKeys.pinned: pinned,
    };
  }
}
