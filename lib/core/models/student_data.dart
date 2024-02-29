import 'package:unn_mobile/core/models/user_data.dart';

class KeysForStudentDataJsonConverter {
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
  final String _eduSpecialization;

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
            userData.sex, userData.urlPhoto);

  String get eduForm => _eduForm;
  String get eduStatus => _eduStatus;
  int get eduCourse => _eduCourse;
  int get eduYear => _eduYear;
  String get eduLevel => _eduLevel;
  String get faculty => _faculty;
  String get eduDirection => _eduDirection;
  String get eduGroup => _eduGroup;
  String get eduSpecialization => _eduSpecialization;

  factory StudentData.fromJson(Map<String, Object?> jsonMap) {
    return StudentData(
      UserData.fromJson(jsonMap),
      jsonMap[KeysForStudentDataJsonConverter.eduForm] as String,
      jsonMap[KeysForStudentDataJsonConverter.eduStatus] as String,
      jsonMap[KeysForStudentDataJsonConverter.eduCourse] as int,
      jsonMap[KeysForStudentDataJsonConverter.eduYear] as int,
      jsonMap[KeysForStudentDataJsonConverter.eduLevel] as String,
      (jsonMap[KeysForStudentDataJsonConverter.faculty]
              as Map<String, Object?>)[KeysForStudentDataJsonConverter.title]
          as String,
      (jsonMap[KeysForStudentDataJsonConverter.eduDirection]
              as Map<String, Object?>)[KeysForStudentDataJsonConverter.title]
          as String,
      (jsonMap[KeysForStudentDataJsonConverter.eduGroup]
              as Map<String, Object?>)[KeysForStudentDataJsonConverter.title]
          as String,
      (jsonMap[KeysForStudentDataJsonConverter.eduSpecialization]
              as Map<String, Object?>)[KeysForStudentDataJsonConverter.title]
          as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json[KeysForStudentDataJsonConverter.eduForm] = _eduForm;
    json[KeysForStudentDataJsonConverter.eduStatus] = _eduStatus;
    json[KeysForStudentDataJsonConverter.eduCourse] = _eduCourse;
    json[KeysForStudentDataJsonConverter.eduYear] = _eduYear;
    json[KeysForStudentDataJsonConverter.eduLevel] = _eduLevel;

    json[KeysForStudentDataJsonConverter.faculty] ??= {};
    json[KeysForStudentDataJsonConverter.faculty]
        [KeysForStudentDataJsonConverter.title] = _faculty;

    json[KeysForStudentDataJsonConverter.eduDirection] ??= {};
    json[KeysForStudentDataJsonConverter.eduDirection]
        [KeysForStudentDataJsonConverter.title] = _eduDirection;

    json[KeysForStudentDataJsonConverter.eduGroup] ??= {};
    json[KeysForStudentDataJsonConverter.eduGroup]
        [KeysForStudentDataJsonConverter.title] = _eduGroup;

    json[KeysForStudentDataJsonConverter.eduSpecialization] ??= {};
    json[KeysForStudentDataJsonConverter.eduSpecialization]
        [KeysForStudentDataJsonConverter.title] = _eduSpecialization;
    return json;
  }
}
