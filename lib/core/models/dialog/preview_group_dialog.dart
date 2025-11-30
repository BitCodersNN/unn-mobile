// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/dialog/chat_settings/base_chat_setting.dart';
import 'package:unn_mobile/core/models/dialog/preview_dialog.dart';

class _PreviewGroupDialogJsonKeys {
  static const String customData = 'customData';
}

class PreviewGroupDialog extends PreviewDialog {
  final BaseChatSetting baseChatSetting;

  PreviewGroupDialog({
    required super.dialogId,
    required super.title,
    required super.avatarUrl,
    required this.baseChatSetting,
  });

  factory PreviewGroupDialog.fromJson(JsonMap json) {
    final dialog = PreviewDialog.fromJson(json, idIsString: true);

    return PreviewGroupDialog(
      dialogId: dialog.dialogId,
      title: dialog.title,
      avatarUrl: dialog.avatarUrl,
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
      _PreviewGroupDialogJsonKeys.customData: {
        ...existingCustomData,
        ...baseChatSetting.toJson(),
      },
    };
  }
}
