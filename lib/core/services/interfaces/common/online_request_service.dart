// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

abstract interface class OnlineRequestService {
  /// Выполняет сетевой запрос без обязательной авторизации на портале
  /// и обновляет статус подключения по результату.
  Future<T?> execute<T>(
    FutureOr<T?> Function() online, {
    FutureOr<T?> Function()? offline,
  });

  /// Гарантирует активную сессию портала, выполняет сетевой запрос
  /// и обновляет статус подключения по результату.
  Future<T?> executeAuthorized<T>(
    FutureOr<T?> Function() online, {
    FutureOr<T?> Function()? offline,
  });
}
