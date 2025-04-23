// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/distance_learning/distance_course.dart';
import 'package:unn_mobile/core/models/distance_learning/semester.dart';

abstract interface class DistanceCourseService {
  /// Асинхронно получает список дистанционных курсов для указанного семестра.
  ///
  /// Метод выполняет GET-запрос к API для получения данных о дистанционных курсах.
  /// В запросе используются параметры [semester.semester] (номер семестра) и [semester.year] (год),
  /// которые извлекаются из переданного объекта [Semester].
  /// Данные ответа декодируются из JSON и преобразуются в список объектов [DistanceCourse].
  ///
  /// Параметры:
  ///   - [semester]: Объект типа [Semester], содержащий номер семестра и год, для которых запрашиваются курсы.
  ///
  /// Возвращает:
  ///   - [Future<List<DistanceCourse>?>]: Список объектов [DistanceCourse], если запрос и обработка данных прошли успешно.
  ///   - `null`, если произошла ошибка при выполнении запроса или если данные ответа имеют неожиданный формат (например, [jsonMap] является списком).
  Future<List<DistanceCourse>?> getDistanceCourses({
    required Semester semester,
  });
}
