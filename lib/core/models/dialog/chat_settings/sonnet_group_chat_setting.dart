// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/dialog/chat_settings/irregular_chat_setting.dart';
import 'package:unn_mobile/core/models/dialog/group_dialog.dart';

final class SonnetGroupChatSetting extends IrregularChatSetting {
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

  factory SonnetGroupChatSetting.fromJson(Map<String, dynamic> json) {
    final chatSetting = IrregularChatSetting.fromJson(json);
    return SonnetGroupChatSetting(
      entityId: chatSetting.entityId,
      url: chatSetting.url,
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
        GroupDialogJsonKeys.type: GroupDialogJsonKeys.sonetGroup,
      };
}
