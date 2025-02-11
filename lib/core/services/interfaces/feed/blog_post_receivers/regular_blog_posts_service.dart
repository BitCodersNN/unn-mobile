import 'package:unn_mobile/core/models/feed/blog_post.dart';

abstract interface class RegularBlogPostsService {
  /// Получает [postsPerPage] постов на странице [pageNumber]
  ///
  /// [pageNumber]: номер страницы, с которой возьмутся посты
  /// [postsPerPage]: количество постов на странице
  ///
  /// Возвращает:
  ///   - [Future<List<BlogPost>?>] - список постов.
  ///   - `null`, если произошла ошибка при выполнении запроса или парсинге данных.
  Future<List<BlogPost>?> getRegularBlogPosts({
    int pageNumber = 1,
    int postsPerPage = 20,
  });
}
