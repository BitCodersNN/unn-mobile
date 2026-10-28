// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

abstract interface class BirthdayGreetingProvider {
  Future<int?> getShownYear(int userId);
  Future<void> saveShownYear(int userId, int year);
}
