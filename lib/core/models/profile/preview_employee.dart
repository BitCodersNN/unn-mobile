import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';

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

class EmployeeProfile {
  final int id;
  final int? departmentId;
  final String jobTitle;
  final List<Department> department;

  EmployeeProfile({
    required this.id,
    required this.departmentId,
    required this.jobTitle,
    required this.department,
  });

  factory EmployeeProfile.fromJson(Map<String, Object?> json) =>
      EmployeeProfile(
        id: json['id'] as int,
        departmentId: int.tryParse(json['department_id'] as String),
        jobTitle: json['job_title'] as String,
        department: (json['department'] as List)
            .map((item) => Department.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

class PreviewEmployee {
  static final String _urlPhotoFirstPart =
      '${ProtocolType.https.name}://${Host.unn}';

  final int userId;
  final String fullname;
  final String? photoSrc;
  final List<EmployeeProfile> profiles;

  PreviewEmployee({
    required this.userId,
    required this.fullname,
    required this.photoSrc,
    required this.profiles,
  });

  factory PreviewEmployee.fromJson(Map<String, Object?> json) {
    final photoSrc = (json['photo'] as Map<String, Object?>)['orig'] as String?;

    return PreviewEmployee(
      userId: json['id'] as int,
      fullname: json['fullname'] as String,
      photoSrc: photoSrc != null ? _urlPhotoFirstPart + photoSrc : null,
      profiles: (json['profiles'] as List)
          .map((item) => EmployeeProfile.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
