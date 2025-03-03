import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/base_options_factory.dart';
import 'package:unn_mobile/core/misc/auth/auth_request_result.dart';
import 'package:unn_mobile/core/misc/auth/authorisation_helper.dart';
import 'package:unn_mobile/core/models/online_status_data.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/unn_authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class UnnAuthorizationServiceImpl extends ChangeNotifier
    implements UnnAuthorisationService {
  late AuthorisationHelper _authorisationHelper;
  final OnlineStatusData _onlineStatus;
  final LoggerService _loggerService;
  final AuthDataProvider _authDataProvider;
  final String _userLogin = 'USER_LOGIN';
  final String _userPassword = 'USER_PASSWORD';
  final String _bxPortatlUnnGuestId = 'BX_PORTAL_UNN_GUEST_ID';

  Map<String, dynamic>? _headers;
  bool _isAuthorised = false;

  @override
  bool get isAuthorised => _isAuthorised;

  @override
  String? get csrf => _headers?[SessionIdentifierStrings.csrf];

  @override
  String? get sessionId =>
      _headers?[SessionIdentifierStrings.sessionIdCookieKey];

  @override
  Map<String, dynamic>? get headers => {
        SessionIdentifierStrings.csrfToken: csrf,
        'Cookie': '${SessionIdentifierStrings.sessionIdCookieKey}=$sessionId',
      };

  @override
  String? get guestId => _headers?[_bxPortatlUnnGuestId];

  UnnAuthorizationServiceImpl(
    this._onlineStatus,
    this._authDataProvider,
    this._loggerService,
  ) {
    _authorisationHelper = AuthorisationHelper(
      _onlineStatus,
      ApiHelper(
        options: createBaseOptions(
          host: Host.unnMobile,
        ),
      ),
      _loggerService,
      ApiPath.authWithCookie,
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
          _userLogin: login,
          _userPassword: password,
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
    _headers = null;
    _isAuthorised = false;
    notifyListeners();
  }

  Future<AuthRequestResult> _auth(Map<String, dynamic> formData) async {
    _isAuthorised = false;
    final result = await _authorisationHelper.auth(
      formData,
    );

    return result.fold(
      (authResult) => _handleAuthResult(authResult),
      (response) => _parseResponse(response),
    );
  }

  Future<AuthRequestResult> _handleAuthResult(
    AuthRequestResult authResult,
  ) async {
    if (authResult == AuthRequestResult.noInternet) {
      _isAuthorised = await _authDataProvider.isContained();
    }
    return authResult;
  }

  AuthRequestResult _parseResponse(Response response) {
    try {
      _headers = _parseHeaders(response.data.trim());
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return AuthRequestResult.unknown;
    }

    _isAuthorised = true;

    _onlineStatus.isOnline = true;
    _onlineStatus.timeOfLastOnline = DateTime.now();

    return AuthRequestResult.success;
  }

  Map<String, dynamic> _parseHeaders(String headers) {
    final Map<String, dynamic> headersMap = {};

    headers.split(';').forEach((cookie) {
      final parts = cookie.split('=');
      if (parts.length == 2) {
        final key = parts[0].trim();
        final value = parts[1].trim();
        headersMap[key] = value;
      }
    });

    return headersMap;
  }
}
