// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/dialog/base_dialog_info.dart';

class _PreviewDialogJsonKeys {
  static const String id = 'id';
  static const String title = 'title';
  static const String avatar = 'avatar';
  static const String customData = 'customData';
}

class PreviewDialog extends BaseDialogInfo {
  PreviewDialog({
    required super.chatId,
    required super.title,
    required super.avatarUrl,
  });

  factory PreviewDialog.fromJson(JsonMap json) => PreviewDialog(
        chatId: (json[_PreviewDialogJsonKeys.customData]
            as JsonMap)[_PreviewDialogJsonKeys.id],
        title: json[_PreviewDialogJsonKeys.title],
        avatarUrl: json[_PreviewDialogJsonKeys.avatar],
      );

  JsonMap toJson() => {
        _PreviewDialogJsonKeys.customData: {
          _PreviewDialogJsonKeys.id: chatId,
        },
        _PreviewDialogJsonKeys.title: title,
        _PreviewDialogJsonKeys.avatar: avatarUrl,
      };
}
