import 'package:unn_mobile/core/providers/interfaces/authorisation/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/session_checker_service.dart';

/// Асинхронно обновляет сессию и выполняет переданную функцию для получения данных.
///
/// Метод проверяет, активна ли текущая сессия с помощью [sessionCheckerService].
/// Если сессия неактивна или статус сессии неизвестен (null), выполняется попытка
/// получить данные авторизации через [authDataProvider] и повторная авторизация
/// через [authorisationService]. После успешного обновления сессии вызывается
/// переданная функция [function], которая возвращает данные типа [T].
///
/// Параметры:
///   - [sessionCheckerService]: Сервис для проверки состояния сессии.
///   - [authorisationService]: Сервис для выполнения авторизации.
///   - [authDataProvider]: Провайдер данных для авторизации (логин и пароль).
///   - [function]: Функция, которая будет выполнена после обновления сессии.
///
/// Возвращает:
///   - [Future<T?>]: Результат выполнения функции [function], если сессия успешно обновлена.
///   - `null`, если сессия неактивна и не удалось выполнить авторизацию,
///     либо если состояние сессии неизвестно.
Future<T?> refreshSessionAndRetrieveData<T>(
  SessionCheckerService sessionCheckerService,
  AuthorisationService authorisationService,
  AuthDataProvider authDataProvider,
  Function function,
) async {
  final isSessionAlive = await sessionCheckerService.isSessionAlive();
  if (isSessionAlive == null) {
    return null;
  }
  if (!isSessionAlive) {
    final authData = await authDataProvider.getData();
    await authorisationService.auth(authData.login, authData.password);
  }

  return function();
}
