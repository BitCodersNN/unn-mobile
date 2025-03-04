import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';

abstract interface class GradeBookService {
  /// Получает зачетную книжку пользователя
  ///
  /// Возвращает [Map]:
  ///   key [int] - номер семестра
  ///   value [List] - список оценок [MarkBySubject]
  /// или null, если:
  ///   1. Не вышло получить ответ от портала
  ///   2. statusCode не равен 200
  ///   3. Не вышло декодировать ответ
  Future<Map<int, List<MarkBySubject>>?> getGradeBook();
}
