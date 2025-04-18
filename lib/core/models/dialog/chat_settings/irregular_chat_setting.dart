import 'package:unn_mobile/core/models/dialog/chat_settings/chat_setting.dart';

class _IrregularChatSettingJsonKeys {
  static const String entityId = 'entity_id';
  static const String entityLink = 'entity_link';
  static const String url = 'url';
}

base class IrregularChatSetting extends ChatSetting {
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

  factory IrregularChatSetting.fromJson(Map<String, dynamic> json) {
    final chatSetting = ChatSetting.fromJson(json);
    return IrregularChatSetting(
      entityId: int.parse(json[_IrregularChatSettingJsonKeys.entityId]),
      url: json[_IrregularChatSettingJsonKeys.entityLink]
          [_IrregularChatSettingJsonKeys.url],
      managerList: chatSetting.managerList,
      muteList: chatSetting.muteList,
      owner: chatSetting.owner,
      role: chatSetting.role,
      userCounter: chatSetting.userCounter,
      permissions: chatSetting.permissions,
      restrictions: chatSetting.restrictions,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        _IrregularChatSettingJsonKeys.entityId: entityId.toString(),
        _IrregularChatSettingJsonKeys.entityLink: {
          _IrregularChatSettingJsonKeys.url: url,
        },
      };
}
