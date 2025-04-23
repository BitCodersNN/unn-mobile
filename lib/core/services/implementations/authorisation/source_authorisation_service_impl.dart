// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
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
}

class SourceAuthorisationServiceImpl extends ChangeNotifier
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

  SourceAuthorisationServiceImpl(
    OnlineStatusData onlineStatus,
    LoggerService loggerService,
  ) {
    _authorisationHelper = AuthorisationHelper(
      onlineStatus,
      ApiHelper(
        options: createBaseOptions(
          host: Host.unnMobile,
        ),
      ),
      loggerService,
      ApiPath.sourceAuth,
    );
  }

  @override
  Future<AuthRequestResult> auth(String login, String password) async {
    try {
      return await _auth(
        {
          _FormDataKeys.login: login,
          _FormDataKeys.password: password,
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
    );

    return result.fold(
      (authResult) => authResult,
      (response) => _parseResponse(response),
    );
  }

  AuthRequestResult _parseResponse(Response response) {
    _sessionId = response.data;
    return AuthRequestResult.success;
  }
}
