// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

abstract interface class ProfilePreview {
  /// Идентификатор профиля на портале.
  int get userId;

  /// Полное имя пользователя.
  String? get fullname;

  /// Адрес фотографии пользователя.
  String? get photoSrc;
}
