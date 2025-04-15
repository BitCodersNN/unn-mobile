import 'package:unn_mobile/core/models/dialog/chat_settings/chat_setting.dart';
import 'package:unn_mobile/core/models/dialog/dialog.dart';

class GroupDialog extends Dialog {
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
}
