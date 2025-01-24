import 'package:unn_mobile/core/models/reference_order/references.dart';

abstract interface class ReferencesService {
  /// Получает справочные данные с сервера.
  ///
  /// Метод выполняет GET-запрос по пути, указанному в [ApiPaths.spravka], используя [ApiHelper].
  /// Если запрос завершается успешно, данные декодируются из JSON и проверяется флаг 'enabled'.
  /// Если флаг 'enabled' равен `false`, возвращается пустой объект [References.empty()].
  /// Если флаг 'enabled' равен `true`, данные преобразуются в объект [References] с помощью метода [References.fromJson].
  ///
  /// В случае возникновения ошибки при выполнении запроса, она логируется с помощью [LoggerService],
  /// и метод возвращает `null`.
  ///
  /// Возвращает:
  ///   - [References], если запрос выполнен успешно и флаг 'enabled' равен `true`.
  ///   - [References.empty()], если запрос выполнен успешно, но флаг 'enabled' равен `false`.
  ///   - `null`, если произошла ошибка при выполнении запроса.
  Future<References?> getReferences();
}
