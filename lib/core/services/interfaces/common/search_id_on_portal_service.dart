import 'package:unn_mobile/core/models/schedule/schedule_search_suggestion_item.dart';
import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';

abstract interface class SearchIdOnPortalService {
  /// Получение ID текущего пользователя, которое используется на unn-portal
  ///
  /// Возвращает [IdForSchedule] или 'null', если не вышло получить ответ от портала или statusCode не равен 200
  Future<IdForSchedule?> getIdOfLoggedInUser();

  /// Получения ID, которое используется на unn-portal
  ///
  /// [value]: Значение, по которому ищется ID
  /// [valueType]: Тип значения: группа или ФИО студента, или ФИО преподователя, или аудитория
  ///
  /// Возвращает [ScheduleSearchSuggestionItem] или 'null', если не вышло получить ответ от портала или statusCode не равен 200
  Future<List<ScheduleSearchSuggestionItem>?> findIdOnPortal(
    String value,
    IdType valueType,
  );
}
