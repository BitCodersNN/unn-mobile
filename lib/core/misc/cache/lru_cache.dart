// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:collection';

class LRUCache<Key, Value> {
  final int maxSize;
  final LinkedHashMap<Key, Value> _cache = LinkedHashMap<Key, Value>();

  LRUCache(this.maxSize) : assert(maxSize >= 0);

  /// Возвращает снимок записей от самой давней к последней использованной.
  Iterable<MapEntry<Key, Value>> get entries =>
      List.unmodifiable(_cache.entries);

  Value? get(Key key) {
    if (!_cache.containsKey(key)) {
      return null;
    }
    final value = _cache.remove(key) as Value;
    _cache[key] = value;
    return value;
  }

  void save(Key key, Value newValue) {
    if (maxSize == 0) {
      return;
    }
    _cache.remove(key);
    _cache[key] = newValue;
    if (_cache.length > maxSize) {
      _cache.remove(_cache.keys.first);
    }
  }

  Value putIfAbsent(Key key, Value Function() ifAbsent) {
    if (_cache.containsKey(key)) {
      return get(key) as Value;
    }
    final value = ifAbsent();
    save(key, value);
    return value;
  }
}
