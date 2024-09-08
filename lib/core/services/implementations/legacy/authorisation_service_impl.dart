import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/custom_errors/auth_errors.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/online_status_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';

class LegacyAuthorizationServiceImpl implements AuthorizationService {
  final OnlineStatusData _onlineStatus;
  String? _sessionId;
  String? _csrf;
  bool _isAuthorised = false;

  LegacyAuthorizationServiceImpl(this._onlineStatus);

  @override
  Future<AuthRequestResult> auth(String login, String password) async {
    if (await _isOffline()) {
      return AuthRequestResult.noInternet;
    }

    HttpClientResponse authResponse;
    HttpClientResponse csrfResponse;

    try {
      authResponse = await _sendAuthRequest(login, password);
    } on TimeoutException {
      return AuthRequestResult.noInternet;
    } on Exception catch (_) {
      rethrow;
    }

    if (authResponse.statusCode != 302) {
      return AuthRequestResult.wrongCredentials;
    }

    final sessionCookie = authResponse.cookies
        .where(
          (cookie) =>
              cookie.name == SessionIdentifierStrings.sessionIdCookieKey,
        )
        .firstOrNull;

    if (sessionCookie == null) {
      throw SessionCookieException(
        message: 'sessionCookie is null',
        privateInformation: {'user_login': login},
      );
    }

    try {
      csrfResponse = await _sendCsrfRequest(sessionCookie.value);
    } on TimeoutException {
      return AuthRequestResult.noInternet;
    } on Exception catch (_) {
      rethrow;
    }

    final csrfValue = csrfResponse.headers.value(
      SessionIdentifierStrings.newCsrf,
    );

    if (csrfValue == null) {
      throw CsrfValueException(
        message: 'csrfValue is null',
        privateInformation: {'user_login': login},
      );
    }

    // bind properties
    _sessionId = sessionCookie.value;
    _csrf = csrfValue;
    _isAuthorised = true;

    // success result
    _onlineStatus.isOnline = true;
    _onlineStatus.timeOfLastOnline = DateTime.now();

    return AuthRequestResult.success;
  }

  @override
  String? get csrf => _csrf;

  @override
  bool get isAuthorised => _isAuthorised;

  @override
  String? get sessionId => _sessionId;

  Future<HttpClientResponse> _sendAuthRequest(
    String login,
    String password,
  ) async {
    final requestSender = HttpRequestSender(
      path: ApiPaths.auth,
      queryParams: {'login': 'yes'},
    );

    return await requestSender.postForm(
      {
        'AUTH_FORM': 'Y',
        'TYPE': 'AUTH',
        'backurl': '/',
        'USER_LOGIN': login,
        'USER_PASSWORD': password,
      },
      timeoutSeconds: 15,
    );
  }

  Future<HttpClientResponse> _sendCsrfRequest(String session) async {
    final requestSender = HttpRequestSender(
      path: ApiPaths.ajax,
      queryParams: {AjaxActionStrings.actionKey: AjaxActionStrings.getNextPage},
      cookies: {SessionIdentifierStrings.sessionIdCookieKey: session},
    );

    return await requestSender.get(timeoutSeconds: 15);
  }

  Future<bool> _isOffline() async {
    return await Connectivity().checkConnectivity() == ConnectivityResult.none;
  }
  
  @override
  String? get guestId => throw UnimplementedError();
}
