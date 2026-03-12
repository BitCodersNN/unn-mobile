// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

/// Класс с константами паттернов форматирования дат.
class DatePattern {
  /// Пример: 2026.01.05
  static const yyyymmddDot = 'yyyy.MM.dd';

  /// Пример: 05.01.2026 14:30:45
  static const ddmmyyyyhhmmss = 'dd.MM.yyyy HH:mm:ss';

  /// Пример: 2026-01-05 14:30:45
  static const yyyymmddhhmmss = 'yyyy-MM-dd HH:mm:ss';

  /// Пример: 05.01.2026
  static const ddmmyyyy = 'dd.MM.yyyy';

  /// Пример: 2026-1-5 14:30
  static const ymmddhm = 'y-MM-dd H:m';

  /// Пример: 2026-01-05
  static const yyyymmddDash = 'yyyy-MM-dd';

  /// Пример: 14:30:45
  static const hhmmss = 'HH:mm:ss';

  /// Пример: 14:30
  static const hhmm = 'HH:mm';

  /// Пример: 5 января
  static const dMMMM = 'd MMMM';

  /// Пример: Пт
  static const e = 'E';

  /// Пример: 5 января 2026 14:30
  static const dmmmmyyyyhhmm = 'd MMMM yyyy HH:mm';

  /// Пример: 5 января 14:30 2026
  static const dmmmmhhmmyyyy = 'd MMMM HH:mm yyyy';
}
