part of '../library.dart';

abstract interface class DataProvider<T> {
  /// Получает данные из хранилища
  ///
  /// Возрващает объект [T]
  Future<T> getData();

  /// Сохраняет данные в хранилище
  Future<void> saveData(T data);

  /// Проверяет наличие данных в хранилище
  Future<bool> isContained();
}
