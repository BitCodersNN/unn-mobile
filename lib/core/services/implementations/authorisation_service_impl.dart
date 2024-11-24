import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper_impl.dart';
import 'package:unn_mobile/core/misc/api_helpers/base_options_factory.dart';
import 'package:unn_mobile/core/models/online_status_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class AuthorizationServiceImpl extends ChangeNotifier
    implements AuthorizationService {
  final OnlineStatusData _onlineStatus;
  final LoggerService _loggerService;
  final String _userLogin = 'USER_LOGIN';
  final String _userPassword = 'USER_PASSWORD';
  final String _bxPortatlUnnGuestId = 'BX_PORTAL_UNN_GUEST_ID';

  Map<String, dynamic>? _cookie;
  bool _isAuthorised = false;

  @override
  bool get isAuthorised => _isAuthorised;

  @override
  Map<String, dynamic>? get cookie => _cookie;

  @override
  String? get csrf => _cookie?[SessionIdentifierStrings.csrf];

  @override
  String? get sessionId =>
      _cookie?[SessionIdentifierStrings.sessionIdCookieKey];

  @override
  String? get guestId => _cookie?[_bxPortatlUnnGuestId];

  AuthorizationServiceImpl(this._onlineStatus, this._loggerService);

  @override
  Future<AuthRequestResult> auth(String login, String password) async {
    try {
      _isAuthorised = false;
      if (await _isOffline()) {
        _onlineStatus.isOnline = false;
        return AuthRequestResult.noInternet;
      }

      final apiHelper = ApiHelperImpl(
        options: createBaseOptions(
          baseUrl: ApiPaths.unnMobileHost,
        ),
      );

      Response response;
      try {
        response = await apiHelper.post(
          path: ApiPaths.authWithCookie,
          data: {
            _userLogin: login,
            _userPassword: password,
          },
        );
        
      } on DioException catch (exc) {
        switch (exc.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.connectionError:
            _onlineStatus.isOnline = false;
            return AuthRequestResult.noInternet;

          case DioExceptionType.badCertificate:
          case DioExceptionType.cancel:
          case DioExceptionType.unknown:
            rethrow;

          case DioExceptionType.badResponse:
            if (exc.response!.statusCode == 401) {
              return AuthRequestResult.wrongCredentials;
            }
            return AuthRequestResult.unknown;
        }
      }

      String responseString;

      try {
        responseString = await apiHelper.responseToStringBody(response);
      } catch (error, stackTrace) {
        _loggerService.logError(error, stackTrace);
        return AuthRequestResult.unknown;
      }

      _cookie = _parseCookies(responseString.trim());

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

  Map<String, dynamic> _parseCookies(String cookies) {
    final Map<String, dynamic> cookieMap = {};

    cookies.split(';').forEach((cookie) {
      final parts = cookie.split('=');
      if (parts.length == 2) {
        final key = parts[0].trim();
        final value = parts[1].trim();
        cookieMap[key] = value;
      }
    });

    return cookieMap;
  }

  Future<bool> _isOffline() async {
    return (await Connectivity().checkConnectivity())
        .contains(ConnectivityResult.none);
  }

  @override
  void logout() {
    _cookie = null;
    _isAuthorised = false;
    notifyListeners();
  }
}
