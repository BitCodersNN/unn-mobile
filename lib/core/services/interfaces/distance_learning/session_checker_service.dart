abstract interface class SessionCheckerService {
  /// Проверяет, активна ли текущая сессия пользователя.
  ///
  /// Метод отправляет POST-запрос на сервер по пути [ApiPath.session] с использованием
  /// [_apiHelper]. В случае успешного выполнения запроса, извлекается ответ сервера,
  /// и из него парсится значение, указывающее на состояние сессии.
  ///
  /// Если запрос завершается ошибкой (например, проблемы с сетью или сервером),
  /// ошибка логируется с помощью [_loggerService], и метод возвращает `null`.
  ///
  /// Возвращает:
  ///   - [Future<bool?>]:
  ///     - `true`, если сессия активна.
  ///     - `false`, если сессия неактивна.
  ///     - `null`, если произошла ошибка при выполнении запроса или парсинге данных.
  Future<bool?> isSessionAlive();
}
