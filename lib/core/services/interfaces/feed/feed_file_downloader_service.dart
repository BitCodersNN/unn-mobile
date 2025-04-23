// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:io';

abstract interface class FeedFileDownloaderService {
  /// Загружает файл с указанным именем [fileName] по URL [downloadUrl].
  ///
  /// [fileName] - имя файла, который нужно загрузить.
  /// [downloadUrl] - URL для загрузки файла.
  /// [force] - если `true`, файл будет загружен повторно, даже если он уже существует.
  ///
  /// Возвращает [File], если загрузка прошла успешно, или `null`, если произошла ошибка.
  Future<File?> downloadFile({
    required String fileName,
    required String downloadUrl,
    required bool force,
  });

  /// Загружает список файлов с именами [fileNames] по URL [downloadUrl].
  ///
  /// [fileNames] - список имен файлов для загрузки.
  /// [downloadUrl] - URL для загрузки файлов.
  /// [force] - если `true`, файлы будут загружены повторно, даже если они уже существуют.
  ///
  /// Возвращает список [File], если загрузка прошла успешно, или `null`, если произошла ошибка.
  Future<List<File>?> downloadFiles({
    required List<String> fileNames,
    required String downloadUrl,
    required bool force,
  });
}
