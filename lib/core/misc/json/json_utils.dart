// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:convert';

typedef JsonMap = Map<String, Object?>;

/// Безопасно декодирует JSON-строку [source], возвращая `null` при ошибке формата.
Object? tryDecodeJson(String source) {
  try {
    return jsonDecode(source);
  } on FormatException {
    return null;
  }
}

/// Безопасно извлекает значение из [json] по ключу [key] и приводит его к типу [T].
///
/// Если ключ отсутствует, либо значение по нему `null` или не может быть приведено к типу [T],
/// возвращается [defaultValue].
T getValueFromJson<T>(JsonMap json, String key, T defaultValue) {
  final value = json[key];
  if (value is T) {
    return value;
  }
  return defaultValue;
}

/// Безопасно извлекает строковое значение из [json] по указанному ключу [key].
///
/// Если [key] отсутствует, либо значение по нему равно `null` или не является
/// строкой ([String]), функция возвращает пустую строку.
String getStringFromJson(JsonMap json, String key) =>
    getValueFromJson(json, key, '');

/// Безопасно извлекает значение из карты [json] по указанному [key] как список.
///
/// Если [key] отсутствует, либо значение по нему равно `null` или не является
/// списком ([List]), метод возвращает пустой список (`[]`).
List getListFromJson(JsonMap json, String key) =>
    getValueFromJson(json, key, []);
