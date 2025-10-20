// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/loading_page/loading_page_data.dart';
import 'package:unn_mobile/core/providers/interfaces/data_provider.dart';

abstract interface class LoadingPageProvider
    implements DataProvider<List<LoadingPageModel>?> {
  /// Загружает список моделей загрузочных страниц из хранилища
  @override
  Future<List<LoadingPageModel>?> getData();

  /// Сохраняет список моделей загрузочных страниц в хранилище
  @override
  Future<void> saveData(List<LoadingPageModel>? loadingPages);

  /// Проверяет, существуют ли сохранённые данные о загрузочных страницах
  @override
  Future<bool> isContained();

  /// Удаляет сохранённые данные о загрузочных страницах из хранилища
  @override
  Future<void> removeData();
}
