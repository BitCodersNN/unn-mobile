// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/feed/blog_post_viewer.dart';

abstract interface class BlogPostViewersService {
  /// Получает страницу пользователей, просмотревших пост.
  ///
  /// [postId] — идентификатор поста.
  /// [pageNumber] — номер страницы, начиная с 1.
  /// Возвращает список просмотров или `null` при ошибке запроса, ответа либо отказе портала.
  /// Некорректные записи пропускаются; для пустой страницы возвращается пустой список.
  Future<List<BlogPostViewer>?> getViewers({
    required int postId,
    int pageNumber = 1,
  });
}
