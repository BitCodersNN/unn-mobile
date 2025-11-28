// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/custom_types/int_or_string.dart';

abstract class BaseDialogInfo {
  final IntOrString dialogId;
  final String title;
  final String avatarUrl;

  BaseDialogInfo({
    required this.dialogId,
    required this.title,
    required this.avatarUrl,
  });
}
