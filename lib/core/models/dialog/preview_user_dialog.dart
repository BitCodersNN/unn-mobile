// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/dialog/preview_dialog.dart';

class _PreviewUserDialogJsonKeys {
  static const String workPosition = 'workPosition';
  static const String lastActivityDate = 'lastActivityDate';
  static const String customData = 'customData';
}

class PreviewUserDialog extends PreviewDialog {
  final DateTime? lastActivityAt;
  final String workPosition;

  PreviewUserDialog({
    required super.chatId,
    required super.title,
    required super.avatarUrl,
    required this.lastActivityAt,
    required this.workPosition,
  });

  factory PreviewUserDialog.fromJson(Map<String, dynamic> json) {
    final dialog = PreviewDialog.fromJson(json);
    return PreviewUserDialog(
      chatId: dialog.chatId,
      title: dialog.title,
      avatarUrl: dialog.avatarUrl,
      lastActivityAt: DateTime.tryParse(
        json[_PreviewUserDialogJsonKeys.customData]
            [_PreviewUserDialogJsonKeys.lastActivityDate],
      ),
      workPosition: json[_PreviewUserDialogJsonKeys.customData]
          [_PreviewUserDialogJsonKeys.workPosition],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final superJson = super.toJson();
    final existingCustomData = superJson[_PreviewUserDialogJsonKeys.customData]
            as Map<String, dynamic>? ??
        {};
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
