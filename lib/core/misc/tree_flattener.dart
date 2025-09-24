// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

/// Преобразует вложенный JSON-объект в плоский список узлов.
///
/// [json] — исходный JSON как Map<String, dynamic>.
/// [rootKey] — ключ корневого узла.
/// [childKey] — ключ, по которому находится дочерний узел.
/// [includeChildField] — оставить ли поле [childKey] в результирующих объектах.
/// [fieldsToKeep] — если задан, включать только указанные поля (например, ['id', 'name']).
List<Map<String, dynamic>> flattenTree({
  required Map<String, dynamic> json,
  required String rootKey,
  required String childKey,
  bool includeChildField = false,
  Set<String>? fieldsToKeep,
}) {
  final List<Map<String, dynamic>> result = [];

  void traverse(Map<String, dynamic>? node) {
    if (node == null || node.isEmpty) return;

    Map<String, dynamic> outputNode;

    if (fieldsToKeep != null) {
      outputNode = {};
      for (final field in fieldsToKeep) {
        if (node.containsKey(field)) {
          outputNode[field] = node[field];
        }
      }
    } else {
      outputNode = Map<String, dynamic>.from(node);
      if (!includeChildField) {
        outputNode.remove(childKey);
      }
    }

    result.add(outputNode);

    final child = node[childKey];
    if (child is Map<String, dynamic>) {
      traverse(child);
    }
  }

  final root = json[rootKey] as Map<String, dynamic>?;
  traverse(root);

  return result;
}
