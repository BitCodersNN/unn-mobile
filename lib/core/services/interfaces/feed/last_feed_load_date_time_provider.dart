import 'package:unn_mobile/core/services/interfaces/data_provider.dart';

abstract interface class LastFeedLoadDateTimeProvider
    implements DataProvider<DateTime?> {
  /// Получает дату последней загрузки новостей
  @override
  Future<DateTime?> getData();

  /// Сохраняет дату последней загрузки новостей
  @override
  Future<void> saveData(DateTime? data);

  /// Проверяет, есть ли данные в хранилище
  @override
  Future<bool> isContained();

  /// Получает дату последней загрузки новостей синхронно <br>
  /// Возвращает null, если данных нет или метод [getData] или [saveData] еще не был вызван
  DateTime? get lastFeedLoadDateTime;
}
