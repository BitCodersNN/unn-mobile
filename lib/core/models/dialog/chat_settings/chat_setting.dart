// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/dialog/chat_settings/base_chat_setting.dart';
import 'package:unn_mobile/core/models/dialog/chat_settings/chat_restrictions.dart';

class _ChatSettingJsonKeys {
  static const String managerList = 'manager_list';
  static const String userCounter = 'user_counter';
  static const String restrictions = 'restrictions';
}

class ChatSetting extends BaseChatSetting {
  final List<int> managerList;
  final int userCounter;
  final ChatRestrictions restrictions;

  ChatSetting({
    required super.muteList,
    required super.owner,
    required super.role,
    required super.permissions,
    required this.managerList,
    required this.userCounter,
    required this.restrictions,
  });

  factory ChatSetting.fromJson(JsonMap json) {
    final baseChatSetting = BaseChatSetting.fromJson(json);
    return ChatSetting(
      muteList: baseChatSetting.muteList,
      owner: baseChatSetting.owner,
      role: baseChatSetting.role,
      permissions: baseChatSetting.permissions,
      managerList:
          List<int>.from(json[_ChatSettingJsonKeys.managerList]! as List),
      userCounter: json[_ChatSettingJsonKeys.userCounter]! as int,
      restrictions: ChatRestrictions.fromJson(
        json[_ChatSettingJsonKeys.restrictions]! as JsonMap,
      ),
    );
  }

  @override
  JsonMap toJson() => {
        ...super.toJson(),
        _ChatSettingJsonKeys.managerList: managerList,
        _ChatSettingJsonKeys.userCounter: userCounter,
        _ChatSettingJsonKeys.restrictions: restrictions.toJson(),
      };
}
