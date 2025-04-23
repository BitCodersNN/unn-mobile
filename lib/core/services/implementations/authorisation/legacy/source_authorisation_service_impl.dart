// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/api/ajax_action.dart';
import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/regular_expressions.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/base_options_factory.dart';
import 'package:unn_mobile/core/misc/authorisation/authorisation_request_result.dart';
import 'package:unn_mobile/core/misc/authorisation/authorisation_helper.dart';
import 'package:unn_mobile/core/models/common/online_status_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/source_authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class _FormDataKeys {
  static const String login = 'login';
  static const String password = 'password';
  static const String submit = 'submit';
}

class _FormDataValues {
  static const String login = 'log-in';
  static const String submit = 'Войти';
}

class LegacySourceAuthorisationServiceImpl extends ChangeNotifier
    implements SourceAuthorisationService {
  late AuthorisationHelper _authorisationHelper;

  String? _sessionId;

  @override
  bool get isAuthorised => sessionId != null;

  @override
  String? get sessionId => _sessionId;

  @override
  Map<String, dynamic>? get headers => {
        'Cookie': '${SessionIdentifierStrings.sessionIdCookieKey}=$sessionId',
      };

  LegacySourceAuthorisationServiceImpl(
    OnlineStatusData onlineStatus,
    LoggerService loggerService,
  ) {
    _authorisationHelper = AuthorisationHelper(
      onlineStatus,
      ApiHelper(
        options: createBaseOptions(
          host: Host.unnSource,
        ),
      ),
      loggerService,
      '',
    );
  }

  @override
  Future<AuthRequestResult> auth(
    String login,
    String password,
  ) async {
    try {
      return await _auth(
        {
          AjaxActionStrings.actionKey: _FormDataValues.login,
          _FormDataKeys.login: login,
          _FormDataKeys.password: password,
          _FormDataKeys.submit: _FormDataValues.submit,
        },
      );
    } finally {
      // Сообщаем, что авторизация могла измениться
      // Это надо делать независимо от того, как мы выйдем отсюда
      // и ТОЛЬКО в конце, когда состояние isAuth уже не изменится
      // до следующего вызова этого метода
      notifyListeners();
    }
  }

  @override
  void logout() {
    _sessionId = null;
    notifyListeners();
  }

  Future<AuthRequestResult> _auth(Map<String, dynamic> formData) async {
    _sessionId = null;

    final result = await _authorisationHelper.auth(
      formData,
      additionalGoodStatusCodes: [302],
    );

    return result.fold(
      (authResult) => authResult,
      (response) => _parseResponse(response),
    );
  }

  AuthRequestResult _parseResponse(Response response) {
    final cookies = response.headers['set-cookie'];
    if (cookies == null) {
      return AuthRequestResult.unknown;
    }

    final regExp = RegularExpressions.phpsessidRegExp;
    final match = regExp.firstMatch(cookies[0]);
    if (match == null) {
      return AuthRequestResult.unknown;
    }

    _sessionId = match.group(1)!;
    return AuthRequestResult.success;
  }
}
