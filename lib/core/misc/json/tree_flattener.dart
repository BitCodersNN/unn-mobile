// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';

/// Преобразует вложенный JSON-объект в плоский список узлов.
///
/// [json] — исходный JSON как JsonMap.
/// [rootKey] — ключ корневого узла.
/// [childKey] — ключ, по которому находится дочерний узел.
/// [includeChildField] — оставить ли поле [childKey] в результирующих объектах.
/// [fieldsToKeep] — если задан, включать только указанные поля (например, ['id', 'name']).
List<JsonMap> flattenTree({
  required JsonMap json,
  required String rootKey,
  required String childKey,
  bool includeChildField = false,
  Set<String>? fieldsToKeep,
}) {
  final List<JsonMap> result = [];

  void traverse(JsonMap? node) {
    if (node == null || node.isEmpty) {
      return;
    }

    JsonMap outputNode;

    if (fieldsToKeep != null) {
      outputNode = {
        for (final field in fieldsToKeep)
          if (node.containsKey(field)) field: node[field],
      };
    } else {
      outputNode = {
        for (final entry in node.entries)
          if (includeChildField || entry.key != childKey)
            entry.key: entry.value,
      };
    }

    result.add(outputNode);

    final child = node[childKey];
    if (child is JsonMap) {
      traverse(child);
    }
  }

  final root = json[rootKey] as JsonMap?;
  traverse(root);

  return result;
}
