import 'package:unn_mobile/core/models/dialog/dialog.dart';

class UserDialog extends Dialog {
  final int id;

  UserDialog({
    required super.chatId,
    required super.title,
    required super.previewMessage,
    required super.lastMessageStatus,
    required super.pinned,
    required this.id,
  });
}
