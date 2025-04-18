import 'package:unn_mobile/core/models/dialog/chat_settings/chat_setting.dart';
import 'package:unn_mobile/core/models/dialog/dialog.dart';

final class GroupDialog extends Dialog {
  final String id;
  final ChatSetting chatSetting;

  GroupDialog({
    required super.chatId,
    required super.title,
    required super.previewMessage,
    required super.lastMessageStatus,
    required super.pinned,
    required this.id,
    required this.chatSetting,
  });

  factory GroupDialog.fromJson(Map<String, dynamic> json) {
    final dialog = Dialog.fromJson(json);
    return GroupDialog(
      chatId: dialog.chatId,
      title: dialog.title,
      previewMessage: dialog.previewMessage,
      lastMessageStatus: dialog.lastMessageStatus,
      pinned: dialog.pinned,
      id: json['id'],
      chatSetting: ChatSetting.fromJson(json['chat']),
    );
  }
}
