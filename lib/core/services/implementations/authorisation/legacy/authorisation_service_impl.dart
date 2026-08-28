// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/api_helpers/base_options_factory.dart';
import 'package:unn_mobile/core/constants/api/ajax_action.dart';
import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/string_keys/session_identifier_keys.dart';
import 'package:unn_mobile/core/misc/authorisation/authorisation_helper.dart';
import 'package:unn_mobile/core/misc/authorisation/authorisation_request_result.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/common/online_status_data.dart';
import 'package:unn_mobile/core/providers/interfaces/authorisation/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/unn_authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class LegacyAuthorizationServiceImpl extends ChangeNotifier
    implements UnnAuthorisationService {
  late AuthorisationHelper _authorisationHelper;
  late ApiHelper _apiHelper;
  final OnlineStatusData _onlineStatus;
  final LoggerService _loggerService;
  final AuthDataProvider _authDataProvider;
  String? _sessionId;
  String? _csrf;
  bool _isAuthorised = false;

  LegacyAuthorizationServiceImpl(
    this._onlineStatus,
    this._authDataProvider,
    this._loggerService,
  ) {
    _apiHelper = ApiHelper(
      options: createBaseOptions(
        host: Host.unn,
      ),
    );

    _authorisationHelper = AuthorisationHelper(
      _onlineStatus,
      _apiHelper,
      _loggerService,
      ApiPath.auth,
    );
  }

  @override
  String? get csrf => _csrf;

  @override
  bool get isAuthorised => _isAuthorised;

  @override
  String? get sessionId => _sessionId;

  @override
  String? get guestId => throw UnimplementedError();

  @override
  Map<String, dynamic>? get headers => {
        SessionIdentifierKeys.csrfToken: csrf,
        'Cookie': '${SessionIdentifierKeys.sessionIdCookieKey}=$sessionId',
      };

  Future<AuthRequestResult> _auth(Map<String, dynamic> formData) async {
    _isAuthorised = false;
    final authResult = await _authorisationHelper.auth(
      formData,
      additionalGoodStatusCodes: [302],
    );

    final interResult = await authResult.fold<Future<AuthRequestResult>>(
      _handleAuthResult,
      _extractSessionCookie,
    );

    if (interResult != AuthRequestResult.success) {
      return interResult;
    }

    Response csrfResponse;
    try {
      csrfResponse = await _apiHelper.get(
        path: ApiPath.ajax,
        queryParameters: {
          AjaxActionStrings.actionKey: AjaxActionStrings.getNextPage,
        },
        options: Options(
          headers: headers,
        ),
      );
    } catch (error, stackTrace) {
      _loggerService.log(
        'Не удалось получить CSRF-токен. Exception: $error\nStackTrace: $stackTrace',
      );
      return AuthRequestResult.unknown;
    }
    final authequestResult = _extractCsrfToken(csrfResponse);

    if (authequestResult == AuthRequestResult.success) {
      _isAuthorised = true;
      _onlineStatus.isOnline = true;
      _onlineStatus.timeOfLastOnline = DateTime.now();
    }

    return authequestResult;
  }

  @override
  Future<AuthRequestResult> auth(String login, String password) async {
    try {
      return await _auth(
        {
          'AUTH_FORM': 'Y',
          'TYPE': 'AUTH',
          'backurl': '/',
          'USER_LOGIN': login,
          'USER_PASSWORD': password,
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

  Future<AuthRequestResult> _handleAuthResult(
    AuthRequestResult authResult,
  ) async {
    if (authResult == AuthRequestResult.noInternet) {
      _isAuthorised = await _authDataProvider.isContained();
    }
    return authResult;
  }

  Future<AuthRequestResult> _extractSessionCookie(Response authResponse) async {
    try {
      _sessionId = authResponse.headers.map['set-cookie']
          ?.firstWhere(
            (cookie) => cookie.startsWith('PHPSESSID='),
            orElse: () => '',
          )
          .split(';')
          .first
          .split('=')
          .last;
    } catch (error, stackTrace) {
      _loggerService.log(
        'Не удалось получить PHPSESSID. Exception: $error\nStackTrace: $stackTrace',
      );
      return AuthRequestResult.unknown;
    }

    if (_sessionId == null) {
      _loggerService.log('PHPSESSID is null');
      return AuthRequestResult.unknown;
    }

    return AuthRequestResult.success;
  }

  AuthRequestResult _extractCsrfToken(Response csrfResponse) {
    try {
      _csrf = ((((csrfResponse.data as JsonMap)['errors']! as List).first
          as JsonMap)['customData']! as JsonMap)['csrf'] as String?;
    } catch (error, stackTrace) {
      _loggerService.log(
        'Не удалось получить CSRF-токен. Exception: $error\nStackTrace: $stackTrace',
      );
      return AuthRequestResult.unknown;
    }

    if (_csrf == null) {
      _loggerService.log('_csrf is null');
      return AuthRequestResult.unknown;
    }

    return AuthRequestResult.success;
  }

  @override
  void logout() {
    _sessionId = null;
    _csrf = null;
    _isAuthorised = false;
    notifyListeners();
  }
}
