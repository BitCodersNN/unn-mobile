// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/git/git_folder.dart';

abstract interface class GitResourceSource<T> {
  /// Каталог ресурса в Git-репозитории.
  GitPath get path;

  /// Загружает и подготавливает ресурс указанной версии.
  Future<T?> load({required String revision});
}
