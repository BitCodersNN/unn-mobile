import 'package:unn_mobile/core/models/user_data.dart';

class KeysForEmployeeDataJsonConverter {
    static const String syncID = 'sync_id';
    static const String jobType = 'job_type';
    static const String jobTitle = 'job_title';
    static const String department = 'department';
    static const String child = 'child';
    static const String title = 'title';
    static const String manager = 'manager';
    static const String fullname = 'fullname';
}

class EmployeeData extends UserData {
  final String _syncID;
  final String _jobType;
  final String _jobTitle;
  final String _department;
  final String _manager;

  EmployeeData(
    UserData userData,
    this._syncID,
    this._jobType,
    this._jobTitle,
    this._department,
    this._manager,
    ): super(userData.login, userData.fullname, userData.email, userData.phone, userData.sex, userData.urlPhoto);

    String get syncID => _syncID;
    String get jobType => _jobType;
    String get jobTitel => _jobTitle;
    String get department => _department;
    String get manager => _manager;

    factory EmployeeData.fromJson(Map<String, Object?> jsonMap) {
      return EmployeeData(
        UserData.fromJson(jsonMap),
        jsonMap[KeysForEmployeeDataJsonConverter.syncID] as String,
        jsonMap[KeysForEmployeeDataJsonConverter.jobType] as String,
        jsonMap[KeysForEmployeeDataJsonConverter.jobTitle] as String,
        ((((jsonMap[KeysForEmployeeDataJsonConverter.department]
         as Map<String, Object?>)[KeysForEmployeeDataJsonConverter.child]
          as Map<String, Object?>)[KeysForEmployeeDataJsonConverter.child])
           as Map<String, Object?>)[KeysForEmployeeDataJsonConverter.title] as String,
        (jsonMap[KeysForEmployeeDataJsonConverter.manager]
         as Map<String, Object?>)[KeysForEmployeeDataJsonConverter.fullname] as String
      );
    }

    @override
    Map<String, dynamic> toJson() => {
      ... super.toJson(),
      KeysForEmployeeDataJsonConverter.syncID: _syncID,
      KeysForEmployeeDataJsonConverter.jobType: _jobType,
      KeysForEmployeeDataJsonConverter.jobTitle: _jobTitle,
      KeysForEmployeeDataJsonConverter.department: {
        KeysForEmployeeDataJsonConverter.child: {
          KeysForEmployeeDataJsonConverter.child: {
            KeysForEmployeeDataJsonConverter.title: _department,
          },
        },
      },
      KeysForEmployeeDataJsonConverter.manager: {
        KeysForEmployeeDataJsonConverter.fullname: _manager,
      },
    };
}
