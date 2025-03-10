import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

/// Преобразует список JSON-объектов в список объектов типа [T].
///
/// [jsonMap] - список динамических JSON-объектов для парсинга.
/// [fromJson] - функция, преобразующая JSON-объект (Map<String, Object?>) в объект типа [T].
/// [loggerService] - сервис для логирования ошибок при сбое парсинга.
///
/// Возвращает список успешно распарсенных объектов типа [T].
/// В случае ошибки элемент пропускается, а ошибка логируется.
///
/// Примечание:
/// - Ошибки парсинга не прерывают выполнение функции.
List<T> parseJsonList<T>(
  List<dynamic> jsonMap,
  T Function(Map<String, Object?>) fromJson,
  LoggerService loggerService,
) {
  final result = <T>[];
  for (final item in jsonMap) {
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
