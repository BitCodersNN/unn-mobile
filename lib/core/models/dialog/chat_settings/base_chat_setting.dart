// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/enum_from_string.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/dialog/chat_settings/chat_permissions.dart';
import 'package:unn_mobile/core/models/dialog/enum/user_role.dart';

class _ChatSettingJsonKeys {
  static const String muteList = 'mute_list';
  static const String owner = 'owner';
  static const String role = 'role';
  static const String permissions = 'permissions';
}

class BaseChatSetting {
  final List<int> muteList;
  final int owner;
  final UserRole role;
  final ChatPermissions permissions;

  BaseChatSetting({
    required this.muteList,
    required this.owner,
    required this.role,
    required this.permissions,
  });

  factory BaseChatSetting.fromJson(JsonMap json) => BaseChatSetting(
        muteList: _parseMuteList(json[_ChatSettingJsonKeys.muteList]),
        owner: json[_ChatSettingJsonKeys.owner] as int,
        role: enumFromString(
          UserRole.values,
          (json[_ChatSettingJsonKeys.role] as String).toLowerCase(),
        ),
        permissions: ChatPermissions.fromJson(
          json[_ChatSettingJsonKeys.permissions] as JsonMap,
        ),
      );

  JsonMap toJson() => {
        _ChatSettingJsonKeys.muteList: _serializeMuteList(muteList),
        _ChatSettingJsonKeys.owner: owner,
        _ChatSettingJsonKeys.role:
            role.toString().split('.').last.toLowerCase(),
        _ChatSettingJsonKeys.permissions: permissions.toJson(),
      };

  static Map<String, bool> _serializeMuteList(List<int> muteList) {
    return {
      for (final userId in muteList) userId.toString(): true,
    };
  }

  static List<int> _parseMuteList(dynamic muteList) {
    if (muteList is! Map) {
      return [];
    }

    return [
      for (final entry in muteList.entries)
        if (entry.value == true) int.parse(entry.key as String),
    ];
  }
}
