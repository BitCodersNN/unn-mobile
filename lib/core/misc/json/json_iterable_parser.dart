// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

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
  T Function(Map<String, dynamic>) fromJson,
  LoggerService loggerService,
) {
  return jsonItems
      .map((item) => _parseItem(item, fromJson, loggerService))
      .whereType<T>()
      .toList();
}

/// Асинхронно преобразует итерируемую коллекцию JSON-объектов в список объектов типа [T].
///
/// [jsonItems] - коллекция динамических JSON-объектов для парсинга.
/// [fromJson] - асинхронная функция преобразования JSON-объекта (Map<String, Object?>)
///              в объект типа [T].
/// [loggerService] - сервис для логирования ошибок при сбое парсинга.
///
/// Возвращает Future со списком успешно распарсенных объектов.
/// Элементы с ошибками пропускаются, а ошибки логируются с указанием проблемного элемента.
///
/// Особенности:
/// - Поддерживает любые итерируемые источники данных (не только списки)
/// - Ошибки парсинга не прерывают обработку всей коллекции
/// - Сохраняет порядок элементов при обработке упорядоченных коллекций
/// - Обрабатывает элементы последовательно (не параллельно)
/// - Возвращает Future, который завершится только после обработки всех элементов
///
/// Используйте эту функцию вместо [parseJsonIterable], когда преобразование [fromJson]
/// требует асинхронных операций (например, обращений к базе данных или сети).
Future<List<T>> parseJsonIterableAsync<T>(
  Iterable<dynamic> jsonItems,
  Future<T> Function(Map<String, dynamic>) fromJson,
  LoggerService loggerService,
) async {
  final results = await Future.wait(
    jsonItems.map((item) => _parseItemAsync(item, fromJson, loggerService)),
  );
  return results.whereType<T>().toList();
}

Future<T?> _parseItemAsync<T>(
  dynamic item,
  Future<T> Function(Map<String, dynamic>) fromJson,
  LoggerService loggerService,
) async {
  if (!_validateItemType<T>(item, loggerService)) return null;

  try {
    return await fromJson(item);
  } catch (exception, stack) {
    loggerService.logError(exception, stack, information: [item]);
    return null;
  }
}

T? _parseItem<T>(
  dynamic item,
  T Function(Map<String, dynamic>) fromJson,
  LoggerService loggerService,
) {
  if (!_validateItemType<T>(item, loggerService)) return null;

  try {
    return fromJson(item);
  } catch (exception, stack) {
    loggerService.logError(exception, stack, information: [item]);
    return null;
  }
}

bool _validateItemType<T>(
  dynamic item,
  LoggerService loggerService,
) {
  if (item is! Map<String, dynamic>) {
    loggerService.logError(
      FormatException('Invalid JSON item type: ${item.runtimeType}'),
      StackTrace.current,
      information: [item],
    );
    return false;
  }
  return true;
}
