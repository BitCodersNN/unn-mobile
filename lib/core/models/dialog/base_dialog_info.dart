// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

abstract class BaseDialogInfo<T> {
  final T dialogId;
  final String title;
  final String avatarUrl;

  BaseDialogInfo({
    required this.dialogId,
    required this.title,
    required this.avatarUrl,
  });
}
