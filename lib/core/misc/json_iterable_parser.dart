import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

/// Преобразует итерируемую коллекцию JSON-объектов в список объектов типа [T].
///
/// [jsonItems] - коллекция динамических JSON-объектов для парсинга.
/// [fromJson] - функция преобразования JSON-объекта (Map<String, Object?>) в объект типа [T].
/// [loggerService] - сервис для логирования ошибок при сбое парсинга.
///
/// Возвращает список успешно распарсенных объектов. 
/// Элементы с ошибками пропускаются, а ошибки логируются с указанием проблемного элемента.
///
/// Примечания:
/// - Поддерживает любые итерируемые источники данных (не только списки)
/// - Ошибки парсинга не прерывают обработку всей коллекции
/// - Гарантирует сохранение порядка элементов при обработке упорядоченных коллекций
List<T> parseJsonIterable<T>(
  Iterable<dynamic> jsonItems,
  T Function(Map<String, Object?>) fromJson,
  LoggerService loggerService,
) {
  final result = <T>[];
  for (final item in jsonItems) {
    try {
      result.add(fromJson(item as Map<String, dynamic>));
    } catch (exception, stack) {
      loggerService.logError(
        exception,
        stack,
        information: [item],
      );
    }
  }
  return result;
}
