// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:io';

abstract interface class LogoDownloaderService {
  /// Загружает файл логотипа с указанным именем [fileName].
  ///
  /// [fileName] - имя файла логотипа, который нужно загрузить.
  ///
  /// Возвращает [File], если загрузка прошла успешно, или `null`, если произошла ошибка.
  Future<File?> downloadFile(String fileName);

  /// Загружает список файлов логотипов с именами [fileNames].
  ///
  /// [fileNames] - список имен файлов логотипов для загрузки.
  ///
  /// Возвращает список [File], если загрузка прошла успешно, или `null`, если произошла ошибка.
  Future<List<File>?> downloadFiles({
    required List<String> fileNames,
  });
}
