// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:io';

abstract interface class AnnouncementImageDownloaderService {
  /// Возвращает локально кешированный и валидный файл изображения [fileName]
  /// без сетевых запросов, либо `null`, если файл отсутствует или повреждён.
  Future<File?> getCachedFile(String fileName);

  /// Загружает файл изображения [fileName] для указанной ревизии [revision].
  Future<File?> downloadFile(String fileName, {required String revision});

  /// Загружает список файлов изображений [fileNames] для ревизии [revision].
  Future<List<File>?> downloadFiles({
    required List<String> fileNames,
    required String revision,
  });
}
