// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/dialog/preview_dialog.dart';

class _PreviewUserDialogJsonKeys {
  static const String workPosition = 'workPosition';
  static const String lastActivityDate = 'lastActivityDate';
  static const String customData = 'customData';
  static const String user = 'user';
}

class PreviewUserDialog extends PreviewDialog {
  final DateTime? lastActivityAt;
  final String workPosition;

  PreviewUserDialog({
    required super.dialogId,
    required super.title,
    required super.avatarUrl,
    required this.lastActivityAt,
    required this.workPosition,
  });

  factory PreviewUserDialog.fromJson(JsonMap json) {
    final dialog = PreviewDialog.fromJson(json, idIsString: false);
    final lastActivityAt = (json[_PreviewUserDialogJsonKeys.customData]!
        as JsonMap)[_PreviewUserDialogJsonKeys.lastActivityDate];
    return PreviewUserDialog(
      dialogId: dialog.dialogId,
      title: dialog.title,
      avatarUrl: dialog.avatarUrl,
      lastActivityAt:
          lastActivityAt is String ? DateTime.tryParse(lastActivityAt) : null,
      workPosition: ((json[_PreviewUserDialogJsonKeys.customData]!
              as JsonMap)[_PreviewUserDialogJsonKeys.user]!
          as JsonMap)[_PreviewUserDialogJsonKeys.workPosition]! as String,
    );
  }

  @override
  JsonMap toJson() {
    final superJson = super.toJson();
    final existingCustomData =
        superJson[_PreviewUserDialogJsonKeys.customData] as JsonMap? ?? {};
    return {
      ...superJson,
      _PreviewUserDialogJsonKeys.customData: {
        ...existingCustomData,
        _PreviewUserDialogJsonKeys.lastActivityDate:
            lastActivityAt?.toIso8601String(),
        _PreviewUserDialogJsonKeys.workPosition: workPosition,
      },
    };
  }
}
