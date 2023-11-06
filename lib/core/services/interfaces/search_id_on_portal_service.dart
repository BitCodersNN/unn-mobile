import 'package:unn_mobile/core/models/schedule_filter.dart';

abstract interface class SearchIdOnPortalService {
  /// Получения ID, которое используется на unn-portal
  ///
  /// [value]: Значение, по которому ищется ID
  /// [valueType]: Тип значения: группа или ФИО студента, или ФИО преподователя, или аудитория
  ///
  /// Возращает словарь (значение: ID) или 'null', если не вышло получить ответ от портала или statusCode не равен 200
  Future<Map<String, String>?> findIDOnPortal(String value, IDType valueType);
}
