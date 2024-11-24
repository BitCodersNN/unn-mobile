import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/online_status_data.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class AuthorizationServiceImpl extends ChangeNotifier
    implements AuthorizationService {
  final OnlineStatusData _onlineStatus;
  final AuthDataProvider _authDataProvider;
  final LoggerService _loggerService;
  final String _userLogin = 'USER_LOGIN';
  final String _userPasswortd = 'USER_PASSWORD';
  final String _bxPortatlUnnGuestId = 'BX_PORTAL_UNN_GUEST_ID';

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

  @override
  String? get guestId => _guestId;

  AuthorizationServiceImpl(
    this._onlineStatus,
    this._loggerService,
    this._authDataProvider,
  );

  @override
  Future<AuthRequestResult> auth(String login, String password) async {
    try {
      _isAuthorised = false;
      if (await _isOffline()) {
        return await _getOfflineResult();
      }

      final requestSender = HttpRequestSender(
        host: ApiPaths.unnMobileHost,
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
        return await _getOfflineResult();
      } on SocketException catch (e) {
        if ({100, 101, 102, 103, 104, 110, 111, 112, 113}
            .contains(e.osError?.errorCode)) {
          return await _getOfflineResult();
        } else {
          rethrow;
        }
      } on Exception catch (_) {
        rethrow;
      }

      if (response.statusCode == 401) {
        return AuthRequestResult.wrongCredentials;
      }

      if (response.statusCode != 200) {
        return AuthRequestResult.unknown;
      }

      String responseString;
      try {
        responseString = await HttpRequestSender.responseToStringBody(response);
      } catch (error, stackTrace) {
        _loggerService.logError(error, stackTrace);
        return AuthRequestResult.unknown;
      }

      _setSessionId(
        _extractValue(
          responseString,
          SessionIdentifierStrings.sessionIdCookieKey,
        ),
      );

      _guestId = _extractValue(responseString, _bxPortatlUnnGuestId);
      _csrf = _extractValue(responseString, SessionIdentifierStrings.csrf);
      _isAuthorised = true;

      _onlineStatus.isOnline = true;
      _onlineStatus.timeOfLastOnline = DateTime.now();

      return AuthRequestResult.success;
    } finally {
      // Сообщаем, что авторизация могла измениться
      // Это надо делать независимо от того, как мы выйдем отсюда
      // и ТОЛЬКО в конце, когда состояние isAuth уже не изменится
      // до следующего вызова этого метода
      notifyListeners();
    }
  }

  Future<AuthRequestResult> _getOfflineResult() async {
    _onlineStatus.isOnline = false;
    _isAuthorised = await _authDataProvider.isContained();
    return AuthRequestResult.noInternet;
  }

  void _setSessionId(String newSessionId) {
    _sessionId = newSessionId;
  }

  String _extractValue(String input, String key) {
    final RegExp regExp = RegExp('$key=([^;]+)');
    final Match? match = regExp.firstMatch(input);
    return match?.group(1) ?? '';
  }

  Future<bool> _isOffline() async {
    return (await Connectivity().checkConnectivity())
        .contains(ConnectivityResult.none);
  }

  @override
  void logout() {
    _sessionId = null;
    _guestId = null;
    _csrf = null;
    _isAuthorised = false;
    notifyListeners();
  }
}
