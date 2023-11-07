import 'package:unn_mobile/core/models/subject.dart';

abstract interface class OfflineScheduleProvider{
  /// Загрузка расписания из хранилища
  /// 
  /// Возращает список предметов или 'null', если нет сохранённого расписания в хранилище
  Future<List<Subject?>> loadSchedule();
  /// Сохраняет расписание в хранилище. Если расписание уже сохранено в хранилище, то старое удаляется и записывается новое
  /// 
  /// [schedule]: Список предметов
  Future<void> saveSchedule(List<Subject> schedule);
}
