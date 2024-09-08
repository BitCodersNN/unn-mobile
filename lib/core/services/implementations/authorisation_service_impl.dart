import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/online_status_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class AuthorizationServiceImpl implements AuthorizationService {
  final OnlineStatusData _onlineStatus;
  final LoggerService _loggerService;
  final String _userLogin = 'USER_LOGIN';
  final String _userPasswortd = 'USER_PASSWORD';

  String? _sessionId;
  String? _csrf;
  String? _guestId;
  bool _isAuthorised = false;

  @override
  String? get csrf => _csrf;

  @override
  bool get isAuthorised => _isAuthorised;

  @override
  String? get sessionId => _sessionId;

  AuthorizationServiceImpl(this._onlineStatus, this._loggerService);

  @override
  Future<AuthRequestResult> auth(String login, String password) async {
    if (await _isOffline()) {
      return AuthRequestResult.noInternet;
    }

    final requestSender = HttpRequestSender(
      host: ApiPaths.mobileHost,
      path: ApiPaths.authWithCookie,
    );

    HttpClientResponse response;
    try {
      response = await requestSender.postForm(
        {
          _userLogin: login,
          _userPasswortd: password,
        },
        timeoutSeconds: 15,
      );
    } on TimeoutException {
      return AuthRequestResult.noInternet;
    } on Exception catch (_) {
      rethrow;
    }
    
    if (response.statusCode == 401) {
      return AuthRequestResult.wrongCredentials;
    }

     if (response.statusCode != 200) {
      return AuthRequestResult.unknown;
    }

    dynamic responseStr;
    try {
      responseStr = await HttpRequestSender.responseToStringBody(response);
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return AuthRequestResult.unknown;
    }

    final List<String> cookies = responseStr.trim().split(';');

    _sessionId = _extractValue(responseStr, SessionIdentifierStrings.sessionIdCookieKey);
    _guestId = _extractValue(responseStr, 'BX_PORTAL_UNN_GUEST_ID');
    _csrf = _extractValue(responseStr, SessionIdentifierStrings.csrf);
    _isAuthorised = true;

    _onlineStatus.isOnline = true;
    _onlineStatus.timeOfLastOnline = DateTime.now();

    return AuthRequestResult.success;
  }

  String _extractValue(String input, String key) {
    final RegExp regExp = RegExp('$key=([^;]+)');
    final Match? match = regExp.firstMatch(input);
    return match?.group(1) ?? '';
  }

  Future<bool> _isOffline() async {
    return await Connectivity().checkConnectivity() == ConnectivityResult.none;
  }
}
