// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:unn_mobile/core/constants/demo_mode.dart';
import 'package:unn_mobile/core/misc/authorisation/authorisation_request_result.dart';
import 'package:unn_mobile/core/misc/demo_mode_status.dart';
import 'package:unn_mobile/core/models/authorisation/auth_data.dart';
import 'package:unn_mobile/core/providers/interfaces/authorisation/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/unn_authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class AuthorisationRefreshServiceImpl implements AuthorisationRefreshService {
  final AuthDataProvider _authDataProvider;
  final UnnAuthorisationService _authorisationService;
  final StorageService _storage;
  final LoggerService _loggerService;

  AuthorisationRefreshServiceImpl(
    this._authDataProvider,
    this._authorisationService,
    this._storage,
    this._loggerService,
  );

  Future<bool> _userDataExistsInStorage() async {
    try {
      final AuthData authData = await _authDataProvider.getData();
      return !(authData.login == AuthData.getDefaultParameter() ||
          authData.login == AuthData.getDefaultParameter());
    } on PlatformException catch (error, stack) {
      _loggerService.logError(
        error,
        stack,
      );
      unawaited(_storage.clear());
      return false;
    }
  }

  @override
  Future<AuthRequestResult?> refreshLogin() async {
    if (!await _userDataExistsInStorage()) {
      _authorisationService.logout();
      return null;
    }
    final AuthData authData = await _authDataProvider.getData();

    const demoPrefixLength = DemoModeConstants.demoUserPrefix.length;

    final shouldEnableDemo =
        authData.login.startsWith(DemoModeConstants.demoUserPrefix);

    final actualLogin = shouldEnableDemo
        ? authData.login.substring(demoPrefixLength)
        : authData.login;

    DemoModeStatus.demoModeEnabled = shouldEnableDemo;

    return _authorisationService.auth(actualLogin, authData.password);
  }
}
