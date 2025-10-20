// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/providers/interfaces/data_provider.dart';

abstract interface class BlogPostProvider
    implements DataProvider<List<BlogPost>?> {
  /// Сохраняет список постов
  @override
  Future<void> saveData(List<BlogPost>? data);

  /// Получает список постов из хранилища
  @override
  Future<List<BlogPost>?> getData();

  /// Проверяет, есть ли данные в хранилище
  @override
  Future<bool> isContained();

  /// Удаляет слхраненный список постов
  @override
  Future<void> removeData();
}
