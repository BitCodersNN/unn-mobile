part of '../library.dart';

abstract interface class GettingFileData {
  /// Получает информацию о файле по id
  ///
  /// Возвращает [FileData] или null, если не вышло получить ответ от портала или statusCode не равен 200
  Future<FileData?> getFileData({
    required int id,
  });
}
