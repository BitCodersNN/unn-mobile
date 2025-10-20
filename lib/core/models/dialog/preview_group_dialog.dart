// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/dialog/chat_settings/base_chat_setting.dart';
import 'package:unn_mobile/core/models/dialog/preview_dialog.dart';

class _PreviewGroupDialogJsonKeys {
  static const String id = 'id';
  static const String customData = 'customData';
}

class PreviewGroupDialog extends PreviewDialog {
  final String id;
  final BaseChatSetting baseChatSetting;

  PreviewGroupDialog({
    required super.chatId,
    required super.title,
    required super.avatarUrl,
    required this.id,
    required this.baseChatSetting,
  });

  factory PreviewGroupDialog.fromJson(JsonMap json) {
    final dialog = PreviewDialog.fromJson(json);

    return PreviewGroupDialog(
      chatId: dialog.chatId,
      title: dialog.title,
      avatarUrl: dialog.avatarUrl,
      id: json[_PreviewGroupDialogJsonKeys.id]! as String,
      baseChatSetting: BaseChatSetting.fromJson(
        json[_PreviewGroupDialogJsonKeys.customData]! as JsonMap,
      ),
    );
  }

  @override
  JsonMap toJson() {
    final superJson = super.toJson();
    final existingCustomData =
        superJson[_PreviewGroupDialogJsonKeys.customData] as JsonMap? ?? {};

    return {
      ...superJson,
      _PreviewGroupDialogJsonKeys.id: id,
      _PreviewGroupDialogJsonKeys.customData: {
        ...existingCustomData,
        ...baseChatSetting.toJson(),
      },
    };
  }
}
