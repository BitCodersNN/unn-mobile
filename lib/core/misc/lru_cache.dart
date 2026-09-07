// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:collection';

class LRUCache<Key, Value> {
  int maxSize;
  LinkedHashMap<Key, Value> cache;

  LRUCache(this.maxSize) : cache = LinkedHashMap<Key, Value>();

  Value? get(Key key) {
    final Value? value = cache.remove(key);
    if (value != null) {
      cache[key] = value;
    }
    return value;
  }

  void save(Key key, Value newValue) {
    final Value? value = cache.remove(key);
    if (value != null) {
      cache[key] = newValue;
    } else {
      if (cache.length >= maxSize) {
        cache.remove(cache.keys.first);
      }
      cache[key] = newValue;
    }
  }

  Value putIfAbsent(Key key, Value Function() ifAbsent) {
    final existing = get(key);
    if (existing != null) {
      return existing;
    }
    final newValue = ifAbsent();
    save(key, newValue);
    return newValue;
  }
}
