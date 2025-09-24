// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

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
        id: json['id'] as int,
        title: json['title'] as String,
        shortTitle: json['short_title'] as String,
      );
}
