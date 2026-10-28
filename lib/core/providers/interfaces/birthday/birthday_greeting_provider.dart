// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

abstract interface class BirthdayGreetingProvider {
  /// Возвращает год последнего показа поздравления пользователю.
  Future<int?> getShownYear(int userId);

  /// Сохраняет год показа поздравления пользователю.
  Future<void> saveShownYear(int userId, int year);

  /// Возвращает идентификатор последнего выбранного поздравления.
  Future<String?> getLastGreetingId(int userId);

  /// Сохраняет идентификатор выбранного поздравления.
  Future<void> saveLastGreetingId(int userId, String greetingId);
}
