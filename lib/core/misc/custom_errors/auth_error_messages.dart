// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/authorisation/authorisation_request_result.dart';

extension AuthRequestResultErrorMessages on AuthRequestResult {
  String get errorMessage => switch (this) {
        AuthRequestResult.success => '',
        AuthRequestResult.wrongCredentials => 'Логин или пароль неверны',
        AuthRequestResult.noInternet => 'Не получилось подключиться к серверу',
        AuthRequestResult.unknown => 'Неизвестная ошибка'
      };
}
