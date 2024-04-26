import 'package:unn_mobile/core/models/user_data.dart';

class _KeysForEmployeeDataJsonConverter {
  static const String user = 'user';
  static const String syncID = 'sync_id';
  static const String jobType = 'job_type';
  static const String jobTitle = 'job_title';
  static const String department = 'department';
  static const String title = 'title';
  static const String manager = 'manager';
  static const String fullname = 'fullname';
}

class EmployeeData extends UserData {
  final String _syncID;
  final String _jobType;
  final String _jobTitle;
  final String _department;
  final String? _manager;

  EmployeeData(
    UserData userData,
    this._syncID,
    this._jobType,
    this._jobTitle,
    this._department,
    this._manager,
  ) : super(userData.login, userData.fullname, userData.email, userData.phone,
            userData.sex, userData.urlPhoto, userData.notes);

  String get syncID => _syncID;
  String get jobType => _jobType;
  String get jobTitle => _jobTitle;
  String get department => _department;
  String? get manager => _manager;

  factory EmployeeData.fromJson(Map<String, Object?> jsonMap) {
    return EmployeeData(
      UserData.fromJson(jsonMap),
      (jsonMap[_KeysForEmployeeDataJsonConverter.user]
              as Map<String, Object?>)[_KeysForEmployeeDataJsonConverter.syncID]
          as String,
      jsonMap[_KeysForEmployeeDataJsonConverter.jobType] as String,
      jsonMap[_KeysForEmployeeDataJsonConverter.jobTitle] as String,
      (jsonMap[_KeysForEmployeeDataJsonConverter.department]
              as Map<String, Object?>)[_KeysForEmployeeDataJsonConverter.title]
          as String,
      (jsonMap[_KeysForEmployeeDataJsonConverter.manager] as Map<String,
          Object?>?)?[_KeysForEmployeeDataJsonConverter.fullname] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json[_KeysForEmployeeDataJsonConverter.user]
        [_KeysForEmployeeDataJsonConverter.syncID] = _syncID;
    json[_KeysForEmployeeDataJsonConverter.jobType] = _jobType;
    json[_KeysForEmployeeDataJsonConverter.jobTitle] = _jobTitle;
    json[_KeysForEmployeeDataJsonConverter.department] ??= {};
    json[_KeysForEmployeeDataJsonConverter.department]
        [_KeysForEmployeeDataJsonConverter.title] = _department;
    json[_KeysForEmployeeDataJsonConverter.manager] ??= {};
    json[_KeysForEmployeeDataJsonConverter.manager]
        [_KeysForEmployeeDataJsonConverter.fullname] = _manager;
    return json;
  }
}
