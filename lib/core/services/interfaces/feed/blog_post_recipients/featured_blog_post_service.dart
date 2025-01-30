import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/models/feed/blog_post_type.dart';

abstract interface class FeaturedBlogPostsService {
  /// Получает список избранных постов, сгруппированных по типу.
  ///
  /// Этот метод выполняет запрос к API для получения избранных записей блога
  /// и возвращает их в виде карты, где ключом является тип записи [BlogPostType],
  /// а значением — список записей [BlogPost].
  ///
  /// Возвращает:
  ///   - Map с ключами [BlogPostType] и списками [BlogPost], если запрос выполнен успешно.
  ///   - `null`, если произошла ошибка при выполнении запроса или парсинге данных.
  Future<Map<BlogPostType, List<BlogPost>>?> getFeaturedBlogPosts();
}
