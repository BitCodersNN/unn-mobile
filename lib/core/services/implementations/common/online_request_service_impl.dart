// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:unn_mobile/core/misc/authorisation/authorisation_request_result.dart';
import 'package:unn_mobile/core/models/common/online_status_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/unn_authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/online_request_service.dart';

class OnlineRequestServiceImpl implements OnlineRequestService {
  final UnnAuthService _authService;
  final AuthRefreshService _authRefreshService;
  final OnlineStatusData _onlineStatus;
  final LoggerService _logger;

  OnlineRequestServiceImpl(
    this._authService,
    this._authRefreshService,
    this._onlineStatus,
    this._logger,
  );

  @override
  Future<T?> execute<T>(
    FutureOr<T?> Function() online, {
    FutureOr<T?> Function()? offline,
  }) async {
    final result = await online();
    if (result != null) {
      _onlineStatus.markOnline();
      return result;
    }
    _onlineStatus.markOffline();
    return offline == null ? null : await offline();
  }

  @override
  Future<T?> executeAuthorized<T>(
    FutureOr<T?> Function() online, {
    FutureOr<T?> Function()? offline,
  }) async {
    if (!await _ensureAuthorized()) {
      return offline == null ? null : await offline();
    }
    return execute(online, offline: offline);
  }

  Future<bool> _ensureAuthorized() async {
    final sessionId = _authService.sessionId;
    if (sessionId != null && sessionId.isNotEmpty && _onlineStatus.isOnline) {
      return true;
    }
    AuthRequestResult? result;
    try {
      result = await _authRefreshService.refreshLogin();
    } catch (error, stackTrace) {
      _logger.logError(error, stackTrace);
    }
    return result == AuthRequestResult.success;
  }
}
