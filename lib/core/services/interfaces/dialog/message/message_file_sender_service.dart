// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:io';

import 'package:unn_mobile/core/models/common/file_data.dart';

abstract interface class MessageFileSenderService {
  /// Отправляет один файл в указанный чат с возможностью добавить текстовое сообщение.
  ///
  /// Параметры:
  ///   - [chatId] - идентификатор чата, в который отправляется файл
  ///   - [file] - файл для отправки
  ///   - [text] - сопроводительный текст к файлу
  ///
  /// Возвращает:
  ///   - [FileData] с информацией об отправленном файле в случае успеха
  ///   - `null` в случае ошибки
  Future<FileData?> sendFile({
    required int chatId,
    required File file,
    required String text,
  });

  /// Отправляет несколько файлов в указанный чат с возможностью добавить текстовое сообщение.
  ///
  /// Параметры:
  ///   - [chatId] - идентификатор чата, в который отправляются файлы
  ///   - [files] - список файлов для отправки
  ///   - [text] - сопроводительный текст к файлам
  ///
  /// Возвращает:
  ///   - Список [FileData] с информацией об отправленных файлах в случае успеха
  ///   - `null` в случае ошибки на любом из этапов
  Future<List<FileData>?> sendFiles({
    required int chatId,
    required List<File> files,
    required String text,
  });
}
