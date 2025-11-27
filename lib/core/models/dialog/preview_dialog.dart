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

class PreviewDialog<T> extends BaseDialogInfo<T> {
  PreviewDialog({
    required super.dialogId,
    required super.title,
    required super.avatarUrl,
  });

  factory PreviewDialog.fromJson(JsonMap json) => PreviewDialog<T>(
        dialogId: T == String
            ? json[_PreviewDialogJsonKeys.id]! as T
            : int.tryParse(json[_PreviewDialogJsonKeys.id]! as String) as T,
        title: json[_PreviewDialogJsonKeys.title]! as String,
        avatarUrl: json[_PreviewDialogJsonKeys.avatar]! as String,
      );

  JsonMap toJson() => {
        _PreviewDialogJsonKeys.customData: {
          _PreviewDialogJsonKeys.id: dialogId,
        },
        _PreviewDialogJsonKeys.title: title,
        _PreviewDialogJsonKeys.avatar: avatarUrl,
      };
}
