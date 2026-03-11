// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/models/feed/blog_post_type.dart';

abstract interface class BlogPostPaginationService {
  /// Загружает следующую страницу списка постов (пагинация).
  ///
  /// Метод предназначен для подгрузки контента, начиная со второй страницы.
  /// На каждой странице ожидается получение списка из 20 постов.
  ///
  /// Выполняет AJAX-запрос к серверу для получения HTML-контента указанной страницы,
  /// затем парсит полученный HTML в структурированные объекты [BlogPost],
  /// сгруппированные по типу [BlogPostType].
  ///
  /// Параметры:
  /// - [pageNumber]: Номер страницы для загрузки.
  /// - [pinIds]: Набор идентификаторов закрепленных постов.
  /// - [signedParameters]: Строка подписанных параметров для валидации запроса.
  /// - [commentFormUID]: Уникальный идентификатор формы комментариев.
  /// - [blogCommentFormUID]: Уникальный идентификатор формы комментариев блога.
  Future<Map<BlogPostType, List<BlogPost>>?> loadNextPageBlogPosts({
    required int pageNumber,
    required Set<int> pinIds,
    required String signedParameters,
    required String commentFormUID,
    required String blogCommentFormUID,
  });
}
