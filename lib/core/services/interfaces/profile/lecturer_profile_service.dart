// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/profile/lecturer_search_result.dart';

abstract interface class LecturerProfileService {
  /// Выполняет поиск профиля преподавателя по ФИО и syncId через постраничный перебор сотрудников
  ///
  /// [fullname]: строка для глобального поиска по ФИО сотрудников
  /// [syncId]: уникальный идентификатор синхронизации, по которому дополнительно проверяется совпадение профиля
  ///
  /// Алгоритм:
  ///   1. Запрашивает сотрудников постранично (по 10 записей)
  ///   2. На каждой странице ищет совпадение по syncId среди найденных сотрудников
  ///   3. Продолжает, пока не найдёт профиль, не встретит ошибку или не закончатся записи
  ///
  /// Возвращает:
  ///   - [LecturerSearchResult.found] — если профиль успешно найден
  ///   - [LecturerSearchResult.error] — если произошла ошибка при поиске внутри страницы или запросе сотрудников
  ///   - [LecturerSearchResult.notFound] — если профиль не найден ни на одной странице
  Future<LecturerSearchResult> getProfile(
    String fullname,
    String syncId,
  );
}
