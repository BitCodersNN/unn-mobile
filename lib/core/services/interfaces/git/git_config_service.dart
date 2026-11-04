// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';

abstract interface class GitConfigService {
  /// Загружает JSON-файл из указанной версии репозитория.
  Future<JsonMap?> getConfig({required String path, required String revision});
}
