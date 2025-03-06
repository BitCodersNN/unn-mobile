import 'package:unn_mobile/core/models/profile/user_short_info.dart';

abstract interface class ImportantBlogPostUsersService {
  /// Возвращает общее количество пользователей, прочитавших важный пост.
  ///
  /// [postId] - идентификатор поста, для которого запрашивается количество пользователей.
  /// Возвращает `int?` - общее количество пользователей или `null`, если произошла ошибка.
  Future<int?> getTotalUserCount(int postId);

  /// Возвращает список пользователей, прочитавших важный пост, с учетом пагинации.
  ///
  /// [postId] - идентификатор поста, для которого запрашиваются пользователи.
  /// [pageNumber] - номер страницы для пагинации (по умолчанию 0).
  /// Возвращает `List<UserShortInfo>?` - список краткой информации о пользователях или `null`, если произошла ошибка.
  Future<List<UserShortInfo>?> getUsers(
    int postId, [
    int pageNumber = 0,
  ]);
}
