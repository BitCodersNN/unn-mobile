// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/authorisation/authorisation_request_result.dart';

abstract interface class AuthorisationService extends Listenable {
  String? get sessionId;
  Map<String, dynamic>? get headers;
  bool get isAuthorised;

  /// Выполняет авторизацию на unn-portal и сохраняет данные авторизации
  ///
  /// [login]: логин на unn-portal, т.е. номер студенческого билета
  /// [password]: пароль
  ///
  /// Возвращает результат авторизаци
  Future<AuthRequestResult> auth(String login, String password);

  /// Очищает данные
  void logout();
}
