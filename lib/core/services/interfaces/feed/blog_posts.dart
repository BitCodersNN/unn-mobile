import 'package:unn_mobile/core/models/feed/blog_post.dart';

abstract interface class BlogPostsService {
  /// Получает 50 записей блоговых постов на конкретной странице
  ///
  /// [pageNumber]: номер страницы, с которой возьмутся записи (по умолчанию 1)
  /// (т.е. на 1-ой странице первые 50 записей, на 2-ой - с 50 по 99 запись и т.д.)
  /// [perpage]: количество записей на странице (по умолчанию 50)
  ///
  /// Возвращает:
  ///   - список [BlogPost]
  ///   - null, если:
  ///     1. Не вышло получить ответ от сервера
  ///     2. statusCode не равен 200
  ///     3. Не вышло декодировать ответ
  ///     4. Не вышло распарсить JSON в объекты [BlogPost]
  Future<List<BlogPost>?> getBlogPosts({int pageNumber = 1, int postsPerPage = 50});
}
