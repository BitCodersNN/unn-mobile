// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

abstract interface class StorageService {
  Future<bool> containsKey({required String key, bool secure = false});
  Future<String?> read({required String key, bool secure = false});
  Future<void> write({
    required String key,
    required String value,
    bool secure = false,
  });
  Future<void> clear();
}
