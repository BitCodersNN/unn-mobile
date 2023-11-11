import 'package:unn_mobile/core/models/schedule_search_result_item.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';

abstract interface class SearchIdOnPortalService {
  /// Получения ID текущего пользователя, которое используется на unn-portal
  /// 
  /// Возращает ID или 'null', если не вышло получить ответ от портала или statusCode не равен 200
  Future<String?> getIdOfLoggedInUser();
  /// Получения ID, которое используется на unn-portal
  ///
  /// [value]: Значение, по которому ищется ID
  /// [valueType]: Тип значения: группа или ФИО студента, или ФИО преподователя, или аудитория
  ///
  /// Возращает [ScheduleSearchResultItem] или 'null', если не вышло получить ответ от портала или statusCode не равен 200
  Future<List<ScheduleSearchResultItem>?> findIDOnPortal(String value, IDType valueType);
}
