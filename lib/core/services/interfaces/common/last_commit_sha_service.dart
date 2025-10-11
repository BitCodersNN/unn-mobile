// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/git/git_folder.dart';

abstract interface class LastCommitShaService {
  /// Получает SHA-хеш последнего коммита для указанного файла в ветке `develop`.
  ///
  /// Метод выполняет HTTP-запрос к API Git-репозитория, чтобы получить информацию
  /// о последнем коммите, затронувшем файл, соответствующий [gitPath].
  /// В случае успешного ответа извлекается и возвращается значение поля `'sha'`.
  ///
  /// gitPath используется для определения пути к файлу:
  /// имя папки преобразуется в snake_case и подставляется в параметр `paths` запроса.
  ///
  /// Возвращает:
  /// - [String] — SHA-хеш последнего коммита, если запрос и извлечение прошли успешно.
  /// - `null` — если произошла ошибка на любом этапе выполнения.
  Future<String?> getSha({
    required GitPath gitPath,
  });
}
