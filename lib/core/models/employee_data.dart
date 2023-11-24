import 'package:unn_mobile/core/models/user_data.dart';

class KeysForEmployeeDataJsonConverter {
    static const String syncID = 'sync_id';

}

class EmployeeData extends UserData {
  final String _syncID;

  EmployeeData(
    UserData userData,
    this._syncID
    ): super(userData.login, userData.fullname, userData.email, userData.phone, userData.sex, userData.urlPhoto);

    String get syncID => _syncID;

    factory EmployeeData.fromJson(Map<String, Object?> jsonMap) {
      return EmployeeData(
        UserData.fromJson(jsonMap),
        jsonMap[KeysForEmployeeDataJsonConverter.syncID] as String,
      );
    }

    @override
    Map<String, dynamic> toJson() => {
      ... super.toJson(),
      KeysForEmployeeDataJsonConverter.syncID: _syncID,
    };
}
