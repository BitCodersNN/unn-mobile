// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/feed/blog_post_comment_data.dart';

abstract interface class GettingBlogPostComments {
  static const commentsPerPage = 20;

  /// Получает список комментариев к блог-посту
  /// [postId] - ID поста
  /// Если [pageNumber] не указан, возвращается 20 последних (самых новых) комментариев
  /// Если требуется посмотреть ранее добавленные комментарии, указывайте [pageNumber]
  ///
  /// Например, пост имеет 45 комментариев, тогда при параметре [pageNumber] =
  ///		1 -> возвращаются последние 20 комментариев
  ///		2 -> возвращаются предыдущие 20 комментариев
  ///		3 -> возвращаются первые 5 комментариев (самые старые)
  ///
  /// Если вдруг, по каким-либо причинам, не удалось декодировать свойства (автор, сообщение, время)
  /// комментария значение таких свойств будет строковый литерал "unknown",
  /// пока ещё ни разу не натыкались на такое
  ///
  /// Возвращает
  ///   - список из [BlogPostCommentData], если всё хорошо
  ///   - пустой список, если комментариев нет
  ///   - null, если:
  ///     1. Не удалось получить ответ от портала
  ///     2. statusCode не равен 200
  ///     3. Не вышло декодировать ответ
  Future<List<BlogPostCommentData>?> getBlogPostComments({
    required int postId,
    int pageNumber = 1,
  });
}
