// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/authorisation/authorisation_request_result.dart';
import 'package:unn_mobile/core/models/common/online_status_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/unn_authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

/// Получает данные или от функции, требующей доступ к серверу, или от функции, использующей локальное хранилище
///
/// Возвращает данные полученные от [online], если есть интернет и сервер работает, иначе возвращает [offline]
Future<T?> tryLoginAndRetrieveData<T>(
  FutureOr<T?> Function() online,
  FutureOr<T?> Function() offline,
) async {
  final LoggerService loggerService = Injector.appInstance.get<LoggerService>();
  final UnnAuthorisationService authorisationService =
      Injector.appInstance.get<UnnAuthorisationService>();
  final AuthorisationRefreshService authorisationRefreshService =
      Injector.appInstance.get<AuthorisationRefreshService>();
  final OnlineStatusData onlineStatus =
      Injector.appInstance.get<OnlineStatusData>();

  if (authorisationService.sessionId == '' || !onlineStatus.isOnline) {
    AuthRequestResult? authRequestResult;
    try {
      authRequestResult = await authorisationRefreshService.refreshLogin();
    } catch (error, stackTrace) {
      loggerService.logError(error, stackTrace);
    }

    if (authRequestResult != AuthRequestResult.success) {
      return await offline();
    }
  }

  T? result = await online();
  if (result != null) {
    onlineStatus.isOnline = true;
    onlineStatus.timeOfLastOnline = DateTime.now();
  } else {
    onlineStatus.isOnline = false;
    result = await offline();
  }

  return result;
}
