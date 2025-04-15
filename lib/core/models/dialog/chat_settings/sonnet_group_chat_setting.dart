import 'package:unn_mobile/core/models/dialog/chat_settings/irregular_chat_setting.dart';

class SonnetGroupChatSetting extends IrregularChatSetting {
  static const String urlTitle = 'Перейти в группу';

  SonnetGroupChatSetting({
    required super.entityId,
    required super.url,
    required super.managerList,
    required super.muteList,
    required super.owner,
    required super.role,
    required super.userCounter,
    required super.permissions,
    required super.restrictions,
  });
}
