import 'package:unn_mobile/core/models/dialog/dialog.dart';

final class UserDialog extends Dialog {
  final int id;

  UserDialog({
    required super.chatId,
    required super.title,
    required super.previewMessage,
    required super.lastMessageStatus,
    required super.pinned,
    required this.id,
  });

  factory UserDialog.fromJson(Map<String, dynamic> json) {
    final dialog = Dialog.fromJson(json);
    return UserDialog(
      chatId: dialog.chatId,
      title: dialog.title,
      previewMessage: dialog.previewMessage,
      lastMessageStatus: dialog.lastMessageStatus,
      pinned: dialog.pinned,
      id: json['id'],
    );
  }
}
