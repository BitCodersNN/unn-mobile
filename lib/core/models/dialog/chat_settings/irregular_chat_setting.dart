import 'package:unn_mobile/core/models/dialog/chat_settings/chat_setting.dart';

abstract class IrregularChatSetting extends ChatSetting {
  final int entityId;
  final String url;

  IrregularChatSetting({
    required this.entityId,
    required this.url,
    required super.managerList,
    required super.muteList,
    required super.owner,
    required super.role,
    required super.userCounter,
    required super.permissions,
    required super.restrictions,
  });
}
