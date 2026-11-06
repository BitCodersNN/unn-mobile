// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

enum ScheduleActivityMode {
  full('full', 'До начала и всю пару'),
  brief('brief', 'До начала и первые минуты пары'),
  disabled('disabled', 'Не показывать');

  final String key;
  final String label;

  const ScheduleActivityMode(this.key, this.label);
}
