// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

/// Безопасно извлекает значение из [json] по ключу [key] и приводит его к типу [T].
///
/// Если ключ отсутствует, либо значение по нему `null` или не может быть приведено к типу [T],
/// возвращается [defaultValue].
T getValueFromJson<T>(Map<String, dynamic> json, String key, T defaultValue) {
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
String getStringFromJson(Map<String, dynamic> json, String key) =>
    getValueFromJson(json, key, '');

/// Безопасно извлекает значение из карты [json] по указанному [key] как список.
///
/// Если ключ [key] отсутствует, значение равно `null` или не является списком
/// ([List]), метод возвращает пустой список (`[]`).
List getListFromJson(Map<String, dynamic> json, String key) =>
    getValueFromJson(json, key, []);
