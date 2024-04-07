import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/services/interfaces/data_provider.dart';

abstract interface class PostWithLoadedInfoProvider
    implements DataProvider<List<PostWithLoadedInfo>?> {
  /// Получение постов из хранилища
  ///
  /// Возвращает список [PostWithLoadedInfo] или 'null', если нет сохранённых постов в хранилище
  @override
  Future<List<PostWithLoadedInfo>?> getData();

  /// Получение даты, когда впоследний раз был выполнен запрос на получение постов с портала, из хранилища
  ///
  /// Возвращает [DateTime] или 'null', если нет сохранённой даты в хранилище
  Future<DateTime?> getDateTimeWhenPostsWereLastGettedFromPoratal();

  /// Проверяет наличие постов в хранилище
  @override
  Future<bool> isContained();

  /// Сохраняет посты в хранилище. Если посты уже сохранены в хранилище, то старые удаляются и записываются новое
  ///
  /// [data]: Список постов
  @override
  Future<void> saveData(List<PostWithLoadedInfo>? data);

  /// Сохраняет дату в хранилище. Если дата уже сохранена в хранилище, то старая удаляется и записывается новая
  ///
  /// [dateTime]: Дата
  Future<void> saveDateTimeWhenPostsWereLastGettedFromPoratal(
    DateTime dateTime,
  );
}
