import 'package:unn_mobile/core/models/feed/blog_post.dart';

abstract interface class RegularBlogPostsService {
  /// Получает [postsPerPage] постов на странице [pageNumber]
  ///
  /// [pageNumber]: номер страницы, с которой возьмутся посты
  /// [postsPerPage]: количество постов на странице
  ///
  /// Возвращает:
  ///   - список [BlogPost]
  ///   - null, если:
  ///     1. Не вышло получить ответ от сервера
  ///     2. statusCode не равен 200
  ///     3. Не вышло декодировать ответ
  ///     4. Не вышло распарсить JSON в объекты [BlogPost]
  Future<List<BlogPost>?> getRegularBlogPosts({
    int pageNumber = 1,
    int postsPerPage = 20,
  });
}
