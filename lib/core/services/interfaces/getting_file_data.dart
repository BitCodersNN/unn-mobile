import 'package:unn_mobile/core/models/file_data.dart';

abstract interface class GettingFileData {
  /// Получает информацию о файле по id
  ///
  /// Возвращает [FileData] или null, если не вышло получить ответ от портала или statusCode не равен 200
  Future<FileData?> getFileData({
    int id = 0,
  });
}
