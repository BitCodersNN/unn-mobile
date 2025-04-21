import 'package:unn_mobile/core/misc/enum_from_string.dart';
import 'package:unn_mobile/core/models/dialog/chat_settings/chat_permissions.dart';
import 'package:unn_mobile/core/models/dialog/chat_settings/chat_restrictions.dart';
import 'package:unn_mobile/core/models/dialog/enum/user_role.dart';

class _ChatSettingJsonKeys {
  static const String managerList = 'manager_list';
  static const String muteList = 'mute_list';
  static const String owner = 'owner';
  static const String role = 'role';
  static const String userCounter = 'user_counter';
  static const String permissions = 'permissions';
  static const String restrictions = 'restrictions';
}

class ChatSetting {
  final List<int> managerList;
  final List<int> muteList;
  final int owner;
  final UserRole role;
  final int userCounter;
  final ChatPermissions permissions;
  final ChatRestrictions restrictions;

  ChatSetting({
    required this.managerList,
    required this.muteList,
    required this.owner,
    required this.role,
    required this.userCounter,
    required this.permissions,
    required this.restrictions,
  });

  factory ChatSetting.fromJson(Map<String, dynamic> json) => ChatSetting(
        managerList:
            List<int>.from(json[_ChatSettingJsonKeys.managerList] as List),
        muteList: _parseMuteList(json[_ChatSettingJsonKeys.muteList]),
        owner: json[_ChatSettingJsonKeys.owner] as int,
        role: enumFromString(
          UserRole.values,
          (json[_ChatSettingJsonKeys.role] as String).toLowerCase(),
        ),
        userCounter: json[_ChatSettingJsonKeys.userCounter] as int,
        permissions: ChatPermissions.fromJson(
          json[_ChatSettingJsonKeys.permissions] as Map<String, dynamic>,
        ),
        restrictions: ChatRestrictions.fromJson(
          json[_ChatSettingJsonKeys.restrictions] as Map<String, dynamic>,
        ),
      );

  Map<String, dynamic> toJson() => {
        _ChatSettingJsonKeys.managerList: managerList,
        _ChatSettingJsonKeys.muteList: _serializeMuteList(muteList),
        _ChatSettingJsonKeys.owner: owner,
        _ChatSettingJsonKeys.role:
            role.toString().split('.').last.toLowerCase(),
        _ChatSettingJsonKeys.userCounter: userCounter,
        _ChatSettingJsonKeys.permissions: permissions.toJson(),
        _ChatSettingJsonKeys.restrictions: restrictions.toJson(),
      };

  static Map<String, bool> _serializeMuteList(List<int> muteList) {
    return {
      for (final userId in muteList) userId.toString(): true,
    };
  }

  static List<int> _parseMuteList(dynamic muteList) {
    if (muteList is! Map) return [];

    return [
      for (final entry in muteList.entries)
        if (entry.value == true) int.parse(entry.key as String),
    ];
  }
}
