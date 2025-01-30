import 'package:unn_mobile/core/models/feed/blog_post.dart';

abstract interface class BlogPostService {
  /// Получает пост по его идентификатору.
  ///
  /// Отправляет GET-запрос к API для получения данных о посте блога.
  /// В случае успеха возвращает объект [BlogPost], иначе возвращает `null`.
  ///
  /// [id] - идентификатор поста блога.
  ///
  /// Возвращает:
  ///   - [Future<BlogPost?>] - объект поста блога
  ///   - `null`, если произошла ошибка при запросе.
  ///
  /// Логирует ошибки и исключения с помощью [LoggerService].
  @override
  Future<BlogPost?> getBlogPost({required int id});
}
