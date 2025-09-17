import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';

class _PreviewStudentDataJsonKeys {
  static const String eduForm = 'edu_form';
  static const String eduCourse = 'edu_course';
  static const String eduLevel = 'edu_level';
  static const String eduDirection = 'edu_direction';
  static const String eduGroup = 'edu_group';
  static const String eduSpecialization = 'edu_specialization';
}

class PreviewStudent {
  static final String _urlPhotoFirstPart =
      '${ProtocolType.https.name}://${Host.unn}';

  final int userId;
  final String? fullname;
  final String? photoSrc;
  final String eduForm;
  final int eduCourse;
  final String eduLevel;
  final String department;
  final String eduDirection;
  final String eduGroup;
  final String? eduSpecialization;

  PreviewStudent({
    required this.userId,
    required this.fullname,
    required this.photoSrc,
    required this.eduForm,
    required this.eduCourse,
    required this.eduLevel,
    required this.department,
    required this.eduDirection,
    required this.eduGroup,
    required this.eduSpecialization,
  });

  factory PreviewStudent.fromJson(Map<String, Object?> json) {
    final photoSrc = (json['photo'] as Map<String, Object?>)['orig'] as String?;

    return PreviewStudent(
      userId: json['user_id'] as int,
      eduForm: json[_PreviewStudentDataJsonKeys.eduForm] as String,
      eduCourse: json[_PreviewStudentDataJsonKeys.eduCourse] as int,
      eduLevel: json[_PreviewStudentDataJsonKeys.eduLevel] as String,
      department: json['department'] as String,
      eduDirection: json[_PreviewStudentDataJsonKeys.eduDirection] as String,
      eduGroup: json[_PreviewStudentDataJsonKeys.eduGroup] as String,
      eduSpecialization:
          json[_PreviewStudentDataJsonKeys.eduSpecialization] as String,
      fullname: json['fullname'] as String,
      photoSrc: photoSrc != null ? _urlPhotoFirstPart + photoSrc : null,
    );
  }
}
