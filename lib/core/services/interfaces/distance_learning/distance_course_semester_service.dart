// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/distance_learning/semester.dart';

abstract interface class DistanceCourseSemesterService {
  /// Асинхронно получает список семестров из API.
  ///
  /// Метод выполняет GET-запрос к API для получения данных о семестрах.
  /// В случае успешного выполнения запроса, данные парсятся с использованием
  /// регулярного выражения [RegularExpressions.distanceCourseSemesterExp].
  ///
  /// Возвращает:
  ///   - [Future<List<Semester>?>]: Список объектов [Semester], если запрос и парсинг прошли успешно.
  ///   - `null`, если произошла ошибка при выполнении запроса или парсинге данных.
  Future<List<Semester>?> getSemesters();
}
