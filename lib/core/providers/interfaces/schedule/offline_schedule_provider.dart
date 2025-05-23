// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/schedule/subject.dart';
import 'package:unn_mobile/core/providers/interfaces/data_provider.dart';

abstract interface class OfflineScheduleProvider
    implements DataProvider<List<Subject>?> {
  /// Загрузка расписания из хранилища
  ///
  /// Возвращает список предметов или 'null', если нет сохранённого расписания в хранилище
  @override
  Future<List<Subject>?> getData();

  /// Сохраняет расписание в хранилище. Если расписание уже сохранено в хранилище, то старое удаляется и записывается новое
  ///
  /// [schedule]: Список предметов
  @override
  Future<void> saveData(List<Subject>? schedule);

  /// Проверяет наличие расписания в хранилище
  @override
  Future<bool> isContained();
}
