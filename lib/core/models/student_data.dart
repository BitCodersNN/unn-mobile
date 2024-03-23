import 'package:unn_mobile/core/models/user_data.dart';

class _KeysForStudentDataJsonConverter {
  static const String eduForm = 'edu_form';
  static const String eduStatus = 'edu_status';
  static const String eduCourse = 'edu_course';
  static const String eduYear = 'edu_year';
  static const String eduLevel = 'edu_level';
  static const String faculty = 'faculty';
  static const String eduDirection = 'edu_direction';
  static const String eduGroup = 'edu_group';
  static const String eduSpecialization = 'edu_specialization';
  static const String title = 'title';
}

class StudentData extends UserData {
  final String _eduForm;
  final String _eduStatus;
  final int _eduCourse;
  final int _eduYear;
  final String _eduLevel;
  final String _faculty;
  final String _eduDirection;
  final String _eduGroup;
  final String? _eduSpecialization;

  StudentData(
      UserData userData,
      this._eduForm,
      this._eduStatus,
      this._eduCourse,
      this._eduYear,
      this._eduLevel,
      this._faculty,
      this._eduDirection,
      this._eduGroup,
      this._eduSpecialization)
      : super(userData.login, userData.fullname, userData.email, userData.phone,
            userData.sex, userData.urlPhoto, userData.notes);

  String get eduForm => _eduForm;
  String get eduStatus => _eduStatus;
  int get eduCourse => _eduCourse;
  int get eduYear => _eduYear;
  String get eduLevel => _eduLevel;
  String get faculty => _faculty;
  String get eduDirection => _eduDirection;
  String get eduGroup => _eduGroup;
  String? get eduSpecialization => _eduSpecialization;

  factory StudentData.fromJson(Map<String, Object?> jsonMap) {
    return StudentData(
      UserData.fromJson(jsonMap),
      jsonMap[_KeysForStudentDataJsonConverter.eduForm] as String,
      jsonMap[_KeysForStudentDataJsonConverter.eduStatus] as String,
      jsonMap[_KeysForStudentDataJsonConverter.eduCourse] as int,
      jsonMap[_KeysForStudentDataJsonConverter.eduYear] as int,
      jsonMap[_KeysForStudentDataJsonConverter.eduLevel] as String,
      (jsonMap[_KeysForStudentDataJsonConverter.faculty]
              as Map<String, Object?>)[_KeysForStudentDataJsonConverter.title]
          as String,
      (jsonMap[_KeysForStudentDataJsonConverter.eduDirection]
              as Map<String, Object?>)[_KeysForStudentDataJsonConverter.title]
          as String,
      (jsonMap[_KeysForStudentDataJsonConverter.eduGroup]
              as Map<String, Object?>)[_KeysForStudentDataJsonConverter.title]
          as String,
      (jsonMap[_KeysForStudentDataJsonConverter.eduSpecialization]
              as Map<String, Object?>?)?[_KeysForStudentDataJsonConverter.title]
          as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json[_KeysForStudentDataJsonConverter.eduForm] = _eduForm;
    json[_KeysForStudentDataJsonConverter.eduStatus] = _eduStatus;
    json[_KeysForStudentDataJsonConverter.eduCourse] = _eduCourse;
    json[_KeysForStudentDataJsonConverter.eduYear] = _eduYear;
    json[_KeysForStudentDataJsonConverter.eduLevel] = _eduLevel;

    json[_KeysForStudentDataJsonConverter.faculty] ??= {};
    json[_KeysForStudentDataJsonConverter.faculty]
        [_KeysForStudentDataJsonConverter.title] = _faculty;

    json[_KeysForStudentDataJsonConverter.eduDirection] ??= {};
    json[_KeysForStudentDataJsonConverter.eduDirection]
        [_KeysForStudentDataJsonConverter.title] = _eduDirection;

    json[_KeysForStudentDataJsonConverter.eduGroup] ??= {};
    json[_KeysForStudentDataJsonConverter.eduGroup]
        [_KeysForStudentDataJsonConverter.title] = _eduGroup;

    json[_KeysForStudentDataJsonConverter.eduSpecialization] ??= {};
    json[_KeysForStudentDataJsonConverter.eduSpecialization]
        [_KeysForStudentDataJsonConverter.title] = _eduSpecialization;
    return json;
  }
}
