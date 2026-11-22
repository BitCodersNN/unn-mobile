// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

typedef JsonMap = Map<String, Object?>;

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

bool parseJsonBool(Object? value, {bool defaultValue = false}) =>
    value is bool ? value : defaultValue;

int? parseJsonInt(Object? value) => switch (value) {
  final int intValue => intValue,
  final num numValue => numValue.toInt(),
  final String stringValue => int.tryParse(stringValue.trim()),
  _ => null,
};

String? readOptionalTrimmedString(Object? value) {
  if (value is! String) {
    return null;
  }
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

List<String>? parseJsonStringList(Object? value) {
  if (value is! List) {
    return null;
  }
  return List.unmodifiable(
    value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty),
  );
}
