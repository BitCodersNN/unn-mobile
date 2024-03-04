import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/models/subject.dart';

abstract interface class GettingScheduleService {
  /// Получение расписания
  ///
  /// [scheduleFilter]: Фильтр, по которому происходит получение расписания
  ///
  /// Возвращает список предметов или 'null', если не вышло получить ответ от портала или statusCode не равен 200
  Future<List<Subject>?> getSchedule(ScheduleFilter scheduleFilter);
}
