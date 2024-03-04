import 'package:unn_mobile/core/models/schedule_search_result_item.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';

abstract interface class SearchIdOnPortalService {
  /// Получение ID текущего пользователя, которое используется на unn-portal
  ///
  /// Возвращает [IDForSchedule] или 'null', если не вышло получить ответ от портала или statusCode не равен 200
  Future<IDForSchedule?> getIdOfLoggedInUser();

  /// Получения ID, которое используется на unn-portal
  ///
  /// [value]: Значение, по которому ищется ID
  /// [valueType]: Тип значения: группа или ФИО студента, или ФИО преподователя, или аудитория
  ///
  /// Возвращает [ScheduleSearchResultItem] или 'null', если не вышло получить ответ от портала или statusCode не равен 200
  Future<List<ScheduleSearchResultItem>?> findIDOnPortal(
      String value, IDType valueType);
}
