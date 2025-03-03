import 'package:unn_mobile/core/models/distance_learning/distance_course.dart';

abstract interface class DistanceCourseService {
  /// Асинхронно получает список дистанционных курсов для указанного семестра и года.
  ///
  /// Метод выполняет GET-запрос к API для получения данных о дистанционных курсах.
  /// В запросе используются параметры [semester] (номер семестра) и [year] (год).
  /// Данные ответа декодируются из JSON и преобразуются в список объектов [DistanceCourse].
  ///
  /// Параметры:
  ///   - [semester]: Номер семестра, для которого запрашиваются курсы.
  ///   - [year]: Год, для которого запрашиваются курсы.
  ///
  /// Возвращает:
  ///   - [Future<List<DistanceCourse>?>]: Список объектов [DistanceCourse], если запрос и обработка данных прошли успешно.
  ///   - `null`, если произошла ошибка при выполнении запроса.
  Future<List<DistanceCourse>?> getDistanceCourses({
    required int semester,
    required int year,
  });
}
