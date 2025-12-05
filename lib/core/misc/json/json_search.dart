import 'package:unn_mobile/core/misc/json/json_utils.dart';

T? findFirstNonNullNotesDeep<T>(dynamic data, String key) {
  if (data is! JsonMap && data is! List) {
    return null;
  }

  if (data is JsonMap && data.containsKey(key) && data[key] is T) {
    return data[key]! as T;
  }

  Iterable<dynamic> items;
  if (data is JsonMap) {
    items = data.values;
  } else {
    items = data;
  }

  for (final item in items) {
    final result = findFirstNonNullNotesDeep<T>(item, key);
    if (result != null) {
      return result;
    }
  }

  return null;
}

void collectFirstValues(
  dynamic data,
  Set<String> keys,
  JsonMap results,
) {
  if (data is! JsonMap && data is! List) {
    return;
  }

  if (results.length == keys.length) {
    return;
  }

  Iterable<dynamic> items;
  if (data is JsonMap) {
    for (final key in keys) {
      if (results.containsKey(key)) {
        continue;
      }
      final value = data[key];
      if (value != null) {
        results[key] = value;
      }
    }
    items = data.values;
  } else {
    items = data;
  }

  for (final item in items) {
    collectFirstValues(item, keys, results);
    if (results.length == keys.length) {
      return;
    }
  }
}
