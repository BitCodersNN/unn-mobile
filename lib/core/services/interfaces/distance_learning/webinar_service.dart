import 'package:unn_mobile/core/models/distance_learning/semester.dart';
import 'package:unn_mobile/core/models/distance_learning/webinar.dart';

abstract interface class WebinarService {
  /// Получает список вебинаров для указанного семестра.
  ///
  /// [semester] - обязательный параметр, определяющий семестр и год,
  /// для которых запрашиваются вебинары.
  ///
  /// Возвращает список объектов типа [Webinar] в случае успешного выполнения запроса.
  /// Если запрос завершается с ошибкой или данные не соответствуют ожидаемому формату,
  /// возвращает `null` и логирует ошибку через [_loggerService].
  ///
  /// Примечание:
  /// - Данные извлекаются из ответа API, который предварительно очищается
  ///   от первых 6 символов перед декодированием JSON.
  /// - Парсинг данных выполняется с использованием функции [parseJsonList]
  ///   и метода [Webinar.fromJson].
  Future<List<Webinar>?> getWebinars({
    required Semester semester,
  });
}
