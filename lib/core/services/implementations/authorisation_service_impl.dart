import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/online_status_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';

class AuthorisationServiceImpl implements AuthorisationService {
  final String _sessionIdCookieKey = "PHPSESSID";
  final String _csrfHeaderName = "x-bitrix-new-csrf";

  String? _sessionId;
  String? _csrf;
  bool _isAuthorised = false;

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
    } on Exception catch (e) {
      log(e.toString());
      return AuthRequestResult.unknownError;
    }

    if (authResponse.statusCode != 302) {
      return AuthRequestResult.wrongCredentials;
    }

    final sessionCookie = authResponse.cookies
        .where((cookie) => cookie.name == _sessionIdCookieKey)
        .firstOrNull;
    if (sessionCookie == null) {
      return AuthRequestResult.unknownError;
    }

    try {
      csrfResponse = await _sendCsrfRequest(sessionCookie.value);
    } on TimeoutException {
      return AuthRequestResult.noInternet;
    } on Exception catch (e) {
      log(e.toString());
      return AuthRequestResult.unknownError;
    }

    final csrfValue = csrfResponse.headers.value(_csrfHeaderName);

    if (csrfValue == null) {
      return AuthRequestResult.unknownError;
    }

    // bind properties
    _sessionId = sessionCookie.value;
    _csrf = csrfValue;
    _isAuthorised = true;

    // success result
    final onlineStatus = Injector.appInstance.get<OnlineStatusData>();
    onlineStatus.isOnline = true;
    onlineStatus.timeOfLastOnline = DateTime.now();

    return AuthRequestResult.success;
  }

  @override
  String? get csrf => _csrf;

  @override
  bool get isAuthorised => _isAuthorised;

  @override
  String? get sessionId => _sessionId;

  Future<HttpClientResponse> _sendAuthRequest(
      String login, String password) async {
    final requestSender =
        HttpRequestSender(path: "auth/", queryParams: {"login": "yes"});

    return await requestSender.postForm({
      "AUTH_FORM": "Y",
      "TYPE": "AUTH",
      "backurl": "/",
      "USER_LOGIN": login,
      "USER_PASSWORD": password,
    }, timeoutSeconds: 15);
  }

  Future<HttpClientResponse> _sendCsrfRequest(String session) async {
    final requestSender = HttpRequestSender(
        path: "bitrix/services/main/ajax.php",
        queryParams: {"action": "socialnetwork.api.livefeed.getNextPage"},
        cookies: {_sessionIdCookieKey: session});

    return await requestSender.get(timeoutSeconds: 15);
  }

  Future<bool> _isOffline() async {
    return await Connectivity().checkConnectivity() == ConnectivityResult.none;
  }
}
