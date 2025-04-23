// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';
import 'package:unn_mobile/core/providers/interfaces/data_provider.dart';

abstract interface class MarkBySubjectProvider
    implements DataProvider<Map<int, List<MarkBySubject>>?> {
  /// Получение зачетной книжки из хранилища
  ///
  /// Возвращает зачетную книжку или 'null', если нет сохранённой зачётной книжки в хранилище
  @override
  Future<Map<int, List<MarkBySubject>>?> getData();

  /// Сохраняет зачетную книжки в хранилище. Если зачетная книжка уже сохранена в хранилище, то старая удаляется и записывается новая
  ///
  /// [recordBook]: зачетная книжка
  @override
  Future<void> saveData(Map<int, List<MarkBySubject>>? recordBook);

  /// Проверяет наличие зачетной книжки в хранилище
  @override
  Future<bool> isContained();
}
