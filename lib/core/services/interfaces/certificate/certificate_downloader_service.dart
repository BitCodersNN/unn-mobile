import 'dart:io';

abstract interface class CertificateDownloaderService {
  /// Загружает файл справки с указанным именем [fileName].
  ///
  /// [fileName] - имя файла, который нужно загрузить.
  ///
  /// Возвращает [File], если загрузка прошла успешно, или null, если произошла ошибка.
  Future<File?> downloadFile(String fileName);
}
