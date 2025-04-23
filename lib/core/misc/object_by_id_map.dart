// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

Map<int, Map> buildObjectByIdMap(List json) {
  return <int, Map<String, dynamic>>{
    for (final object in json.cast<Map<String, dynamic>>())
      object['id'] as int: object,
  };
}
