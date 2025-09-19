// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/objects_with_pagination.dart';
import 'package:unn_mobile/core/models/profile/preview_employee.dart';
import 'package:unn_mobile/core/models/profile/preview_student.dart';
import 'package:unn_mobile/core/models/profile/search_filter.dart';
import 'package:unn_mobile/core/models/profile/sort_field.dart';

abstract interface class SearchService {
  /// Возвращает список предварительных данных студентов на основе заданных критериев поиска и пагинации.
  ///
  /// Возвращает [ResultWithTotal<PreviewStudent>?], содержащий:
  ///   - [items]: список объектов [PreviewStudent] — предпросмотры студентов, соответствующих фильтру.
  ///   - [total]: общее количество записей на сервере, соответствующих фильтру (для пагинации).
  ///
  /// В случае ошибки (например, сетевой сбой, таймаут или ошибка парсинга JSON):
  ///   - Возвращает `null`.
  Future<ResultWithTotal<PreviewStudent>?> getStudents(
    SearchFilter searchFilter, {
    int ordinalNumberFirst = 0,
    int count = 10,
    SortField sortField = SortField.fullname,
    bool reverse = false,
  });

  /// Возвращает список предварительных данных сотрудников на основе заданных критериев поиска и пагинации.
  ///
  /// Возвращает [ResultWithTotal<PreviewEmployee>?], содержащий:
  ///   - [items]: список объектов [PreviewEmployee] — предпросмотры сотрудников, соответствующих фильтру.
  ///   - [total]: общее количество записей на сервере, соответствующих фильтру (для реализации пагинации на клиенте).
  ///
  /// В случае ошибки (например, сетевой сбой, таймаут или ошибка парсинга JSON):
  ///   ///   - Возвращает `null`.
  Future<ResultWithTotal<PreviewEmployee>?> getEmployees(
    EmployeeSearchFilter searchFilter, {
    int ordinalNumberFirst = 0,
    int count = 10,
    bool reverse = false,
  });
}
