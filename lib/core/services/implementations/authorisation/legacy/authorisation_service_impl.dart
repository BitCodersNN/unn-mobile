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
  late final AuthorisationHelper _authorisationHelper;
  late final ApiHelper _apiHelper;

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
      options: createBaseOptions(host: Host.unn),
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
  String? get guestId => null;

  @override
  Map<String, dynamic>? get headers {
    if (_sessionId == null) {
      return null;
    }

    final result = <String, dynamic>{
      'Cookie': '${SessionIdentifierKeys.sessionIdCookieKey}=$_sessionId',
    };

    if (_csrf != null) {
      result[SessionIdentifierKeys.csrfToken] = _csrf;
    }

    return result;
  }

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

    final Response csrfResponse;
    try {
      csrfResponse = await _apiHelper.get(
        path: ApiPath.ajax,
        queryParameters: {
          AjaxActionStrings.actionKey: AjaxActionStrings.getNextPage,
        },
        options: Options(headers: headers),
      );
    } catch (error, stackTrace) {
      _loggerService.log(
        'Не удалось выполнить запрос для получения CSRF-токена. Exception: $error\nStackTrace: $stackTrace',
      );
      return AuthRequestResult.unknown;
    }

    final authRequestResult = _extractCsrfToken(csrfResponse);

    if (authRequestResult == AuthRequestResult.success) {
      _isAuthorised = true;
      _onlineStatus.isOnline = true;
      _onlineStatus.timeOfLastOnline = DateTime.now();
    }

    return authRequestResult;
  }

  @override
  Future<AuthRequestResult> auth(String login, String password) async {
    try {
      return await _auth({
        'AUTH_FORM': 'Y',
        'TYPE': 'AUTH',
        'backurl': '/',
        'USER_LOGIN': login,
        'USER_PASSWORD': password,
      });
    } finally {
      // Сообщаем слушателям об изменении состояния авторизации.
      // Это должно происходить строго в конце, когда состояние _isAuthorised уже стабилизировалось.
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
      final cookies = authResponse.headers.map['set-cookie'];

      if (cookies == null || cookies.isEmpty) {
        _loggerService
            .log('Отсутствуют заголовки set-cookie в ответе авторизации');
        return AuthRequestResult.unknown;
      }

      final sessionCookie = cookies.firstWhere(
        (cookie) => cookie.startsWith('PHPSESSID='),
        orElse: () => '',
      );

      if (sessionCookie.isEmpty) {
        _loggerService.log('PHPSESSID не найден в заголовках set-cookie');
        return AuthRequestResult.unknown;
      }

      _sessionId = sessionCookie.split(';').first.split('=').last.trim();

      if (_sessionId!.isEmpty) {
        _loggerService.log('Значение PHPSESSID оказалось пустым');
        return AuthRequestResult.unknown;
      }
    } catch (error, stackTrace) {
      _loggerService.log(
        'Не удалось получить PHPSESSID. Exception: $error\nStackTrace: $stackTrace',
      );
      return AuthRequestResult.unknown;
    }

    return AuthRequestResult.success;
  }

  AuthRequestResult _extractCsrfToken(Response csrfResponse) {
    try {
      // Оставляем каскадное приведение типов, как вы и просили.
      // Любая ошибка здесь будет перехвачена блоком catch ниже.
      _csrf = ((((csrfResponse.data as JsonMap)['errors']! as List).first
          as JsonMap)['customData']! as JsonMap)['csrf'] as String?;
    } catch (error, stackTrace) {
      _loggerService.log(
        'Не удалось получить CSRF-токен. Exception: $error\nStackTrace: $stackTrace',
      );
      return AuthRequestResult.unknown;
    }

    if (_csrf == null || _csrf!.isEmpty) {
      _loggerService.log('_csrf is null or empty');
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
