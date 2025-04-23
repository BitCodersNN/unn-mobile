// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/distance_learning/distance_file_data.dart';
import 'package:unn_mobile/core/models/distance_learning/distance_link_data.dart';
import 'package:unn_mobile/core/models/distance_learning/distance_material_data.dart';
import 'package:unn_mobile/core/models/distance_learning/semester.dart';

class DistanceCourseJsonKeys {
  static const String discipline = 'discipline';
  static const String login = 'login';
  static const String groups = 'groups';
  static const String files = 'files';
  static const String links = 'links';
}

class DistanceCourse {
  final Semester semester;
  final String discipline;
  final String employeeLogin;
  final List<String> groups;
  final List<DistanceMaterialData> materials;

  DistanceCourse({
    required this.semester,
    required this.discipline,
    required this.employeeLogin,
    required this.groups,
    required this.materials,
  });

  factory DistanceCourse.fromJson(Map<String, Object?> jsonMap) =>
      DistanceCourse(
        semester: Semester.fromJson(jsonMap),
        discipline: jsonMap[DistanceCourseJsonKeys.discipline] as String,
        employeeLogin: jsonMap[DistanceCourseJsonKeys.login] as String,
        groups: (jsonMap[DistanceCourseJsonKeys.groups] as String)
            .split('|')
            .where((element) => element.isNotEmpty)
            .toSet()
            .toList(),
        materials: _parseMaterials(jsonMap),
      );

  Map<String, Object?> toJson() => {
        ...semester.toJson(),
        DistanceCourseJsonKeys.discipline: discipline,
        DistanceCourseJsonKeys.login: employeeLogin,
        DistanceCourseJsonKeys.groups: groups.join('|'),
        DistanceCourseJsonKeys.files:
            materials.map((file) => file.toJson()).toList(),
      };

  static List<DistanceMaterialData> _parseMaterials(
    Map<String, Object?> jsonMap,
  ) {
    final files = jsonMap[DistanceCourseJsonKeys.files] as List<dynamic>? ?? [];
    final links = jsonMap[DistanceCourseJsonKeys.links] as List<dynamic>? ?? [];

    final fileDataList = files
        .map((materialJson) => DistanceFileData.fromJson(materialJson))
        .toList();
    final linkDataList = links
        .map((materialJson) => DistanceLinkData.fromJson(materialJson))
        .toList();

    return [...fileDataList, ...linkDataList];
  }
}
