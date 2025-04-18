import 'package:unn_mobile/core/misc/enum_to_string.dart';
import 'package:unn_mobile/core/models/dialog/chat_settings/chat_permissions.dart';
import 'package:unn_mobile/core/models/dialog/chat_settings/chat_restrictions.dart';
import 'package:unn_mobile/core/models/dialog/enum/user_role.dart';

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
        managerList: List<int>.from(json['manager_list'] as List),
        muteList: _parseMuteList(json['mute_list']),
        owner: json['owner'] as int,
        role: enumFromString(
          UserRole.values,
          (json['role'] as String).toLowerCase(),
        ),
        userCounter: json['user_counter'] as int,
        permissions: ChatPermissions.fromJson(
            json['permissions'] as Map<String, dynamic>),
        restrictions: ChatRestrictions.fromJson(
            json['restrictions'] as Map<String, dynamic>),
      );

  static List<int> _parseMuteList(dynamic muteList) {
    if (muteList is! Map) return [];

    return [
      for (final entry in muteList.entries)
        if (entry.value == true) int.parse(entry.key as String),
    ];
  }
}
