// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

class _DepartmentJsonKeys {
  static const String id = 'id';
  static const String title = 'title';
  static const String shortTitle = 'short_title';
}

class Department {
  final int id;
  final String title;
  final String shortTitle;

  Department({
    required this.id,
    required this.title,
    required this.shortTitle,
  });

  factory Department.fromJson(Map<String, Object?> json) => Department(
        id: json[_DepartmentJsonKeys.id] as int,
        title: json[_DepartmentJsonKeys.title] as String,
        shortTitle: json[_DepartmentJsonKeys.shortTitle] as String,
      );
}
