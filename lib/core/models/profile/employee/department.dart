// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';

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

  factory Department.fromJson(JsonMap json) => Department(
        id: json[_DepartmentJsonKeys.id] as int,
        title: json[_DepartmentJsonKeys.title] as String,
        shortTitle: json[_DepartmentJsonKeys.shortTitle] as String,
      );

  JsonMap toJson() => {
        _DepartmentJsonKeys.id: id,
        _DepartmentJsonKeys.title: title,
        _DepartmentJsonKeys.shortTitle: shortTitle,
      };
}
