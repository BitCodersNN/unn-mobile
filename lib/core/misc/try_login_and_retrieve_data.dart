import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/online_status_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

/// Получает данные или от функции, требующей доступ к серверу, или от функции, использующей локальное хранилище
///
/// Возвращает данные полученные от [online], если есть интернет и сервер работает, иначе возвращает [offline]
Future<T?> tryLoginAndRetrieveData<T>(Function online, Function offline) async {
  final LoggerService loggerService = Injector.appInstance.get<LoggerService>();
  final AuthorizationService authorisationService =
      Injector.appInstance.get<AuthorizationService>();
  final AuthorizationRefreshService authorisationRefreshService =
      Injector.appInstance.get<AuthorizationRefreshService>();
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
