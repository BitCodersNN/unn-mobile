// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/custom_types/int_or_string.dart';
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
    required super.dialogId,
    required super.title,
    required super.avatarUrl,
  });

  factory PreviewDialog.fromJson(JsonMap json, {required bool isString}) =>
      PreviewDialog(
        dialogId: isString
            ? StringValue(json[_PreviewDialogJsonKeys.id]! as String)
            : IntValue(
                int.tryParse(json[_PreviewDialogJsonKeys.id]! as String)!,
              ),
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
