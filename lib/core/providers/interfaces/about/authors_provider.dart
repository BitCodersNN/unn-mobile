// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/about/author.dart';
import 'package:unn_mobile/core/providers/interfaces/data_provider.dart';

abstract interface class AuthorsProvider
    implements DataProvider<Map<String, List<Author>>?> {
  /// Загружает данные об авторах из хранилища
  @override
  Future<Map<String, List<Author>>?> getData();

  /// Сохраняет данные об авторах в хранилище
  @override
  Future<void> saveData(Map<String, List<Author>>? loadingPages);

  /// Проверяет, содержит ли хранилище сохранённую информацию об авторах
  @override
  Future<bool> isContained();

  /// Удаляет данные об авторах из хранилища
  @override
  Future<void> removeData();
}
