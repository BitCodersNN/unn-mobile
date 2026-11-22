// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/profile/employee/employee_data.dart';
import 'package:unn_mobile/core/models/profile/student/student_data.dart';

enum AnnouncementCategory {
  giveaway(
    fileName: 'giveaways.json',
    defaultPriority: 20,
    defaultBadge: 'РОЗЫГРЫШ',
  ),
  ad(fileName: 'ads.json', defaultPriority: 10, defaultBadge: 'РЕКЛАМА'),
  update(
    fileName: 'updates.json',
    defaultPriority: 30,
    defaultBadge: 'ОБНОВЛЕНИЕ',
  );

  final String fileName;
  final int defaultPriority;
  final String defaultBadge;

  const AnnouncementCategory({
    required this.fileName,
    required this.defaultPriority,
    required this.defaultBadge,
  });

  static AnnouncementCategory fromName(
    String? name, {
    AnnouncementCategory fallback = AnnouncementCategory.giveaway,
  }) => switch (name?.trim().toLowerCase()) {
    'giveaway' || 'giveaways' => AnnouncementCategory.giveaway,
    'ad' || 'ads' => AnnouncementCategory.ad,
    'update' || 'updates' => AnnouncementCategory.update,
    _ => fallback,
  };
}

enum AnnouncementAnimation {
  defaultAnimation('default'),
  f1Tow('f1_tow');

  final String value;

  const AnnouncementAnimation(this.value);

  static AnnouncementAnimation fromName(String? name) =>
      name?.trim().toLowerCase() == f1Tow.value ? f1Tow : defaultAnimation;
}

enum AnnouncementUserType {
  all('all'),
  student('student'),
  employee('employee');

  final String value;

  const AnnouncementUserType(this.value);

  static AnnouncementUserType fromName(String? name) =>
      switch (name?.trim().toLowerCase()) {
        'student' || 'students' => AnnouncementUserType.student,
        'employee' || 'employees' => AnnouncementUserType.employee,
        _ => AnnouncementUserType.all,
      };

  bool matches(Type? userRuntimeType) => switch (this) {
    AnnouncementUserType.all => true,
    AnnouncementUserType.student => userRuntimeType == StudentData,
    AnnouncementUserType.employee => userRuntimeType == EmployeeData,
  };
}

enum AnnouncementChannel {
  all('all'),
  stable('stable'),
  beta('beta');

  final String value;

  const AnnouncementChannel(this.value);

  static AnnouncementChannel fromName(String? name) =>
      switch (name?.trim().toLowerCase()) {
        'stable' => AnnouncementChannel.stable,
        'beta' => AnnouncementChannel.beta,
        _ => AnnouncementChannel.all,
      };

  bool matches({required bool isTesting}) => switch (this) {
    AnnouncementChannel.all => true,
    AnnouncementChannel.stable => !isTesting,
    AnnouncementChannel.beta => isTesting,
  };
}

enum AnnouncementFrequency {
  once('once'),
  everyLaunch('every_launch'),
  oncePerDay('once_per_day'),
  intervalHours('interval_hours');

  final String value;

  const AnnouncementFrequency(this.value);

  static AnnouncementFrequency fromName(
    String? name, {
    AnnouncementFrequency fallback = AnnouncementFrequency.oncePerDay,
  }) => switch (name?.trim().toLowerCase()) {
    'once' => AnnouncementFrequency.once,
    'every_launch' => AnnouncementFrequency.everyLaunch,
    'once_per_day' => AnnouncementFrequency.oncePerDay,
    'interval_hours' => AnnouncementFrequency.intervalHours,
    _ => fallback,
  };
}
