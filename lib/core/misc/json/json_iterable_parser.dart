// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

/// Преобразует итерируемую коллекцию JSON-объектов в список объектов типа [T].
///
/// [jsonItems] - коллекция динамических JSON-объектов для парсинга.
/// [fromJson] - функция преобразования JSON-объекта (Map<String, Object?>) в объект типа [T].
///             Может возвращать как [T], так и [Future<T>].
/// [loggerService] - сервис для логирования ошибок при сбое парсинга.
///
/// Возвращает [FutureOr<List<T>>], содержащий список успешно распарсенных объектов.
/// Если все элементы обработаны синхронно — вернёт [List<T>], иначе — [Future<List<T>>].
/// Элементы с ошибками пропускаются, а ошибки логируются с указанием проблемного элемента.
///
/// Примечания:
/// - Поддерживает любые итерируемые источники данных (не только списки)
/// - Ошибки парсинга не прерывают обработку всей коллекции
/// - Гарантирует сохранение порядка элементов при обработке упорядоченных коллекций
FutureOr<List<T>> parseJsonIterable<T>(
  Iterable<dynamic> jsonItems,
  FutureOr<T> Function(Map<String, dynamic>) fromJson,
  LoggerService loggerService,
) {
  return jsonItems
      .map((item) => _parseItem(item, fromJson, loggerService))
      .whereType<T>()
      .toList();
}

FutureOr<T?> _parseItem<T>(
  dynamic item,
  FutureOr<T> Function(Map<String, dynamic>) fromJson,
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
