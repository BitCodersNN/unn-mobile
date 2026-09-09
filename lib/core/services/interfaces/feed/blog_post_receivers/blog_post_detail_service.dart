// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/feed/blog_post.dart';

abstract interface class BlogPostDetailService {
  /// Получает блог-пост по его уникальному идентификатору.
  ///
  /// Выполняет GET-запрос к серверу по адресу `ApiPath.blogPost/$postId/`
  /// с таймаутами на отправку и получение данных, установленными в 30 секунд.
  /// Получает HTML-разметку новой ленты постов и парсит её в структурированные объекты.
  ///
  /// Параметры:
  /// - [postId]: Целочисленный идентификатор запрашиваемого поста.
  ///
  /// Возвращает: [Future]<[BlogPost]?>` – объект поста или `null` при ошибке.
  Future<BlogPost?> getBlogPostById({
    required int postId,
  });
}
