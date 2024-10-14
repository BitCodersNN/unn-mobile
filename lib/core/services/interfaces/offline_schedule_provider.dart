part of '../library.dart';

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
