// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

class ScheduleActivityCapabilities {
  final bool supported;
  final bool authorized;
  final bool exactAlarms;

  const ScheduleActivityCapabilities({
    required this.supported,
    required this.authorized,
    required this.exactAlarms,
  });

  factory ScheduleActivityCapabilities.fromMap(Map<Object?, Object?> data) =>
      ScheduleActivityCapabilities(
        supported: data['supported'] == true,
        authorized: data['authorized'] == true,
        exactAlarms: data['exactAlarms'] != false,
      );
}
