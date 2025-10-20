// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/providers/interfaces/data_provider.dart';

abstract interface class LastCommitShaProvider
    implements DataProvider<String?> {
  /// Загружает сохранённый SHA-хэш последнего коммита из хранилища
  @override
  Future<String?> getData();

  /// Сохраняет SHA-хэш последнего коммита в хранилище
  @override
  Future<void> saveData(String? loadingPages);

  /// Проверяет, существует ли сохранённый SHA-хэш последнего коммита
  @override
  Future<bool> isContained();

  /// Удаляет сохранённый SHA-хэш последнего коммита из хранилища
  @override
  Future<void> removeData();
}
