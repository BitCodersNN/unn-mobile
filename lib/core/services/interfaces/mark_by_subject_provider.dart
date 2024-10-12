part of '../library.dart';

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
