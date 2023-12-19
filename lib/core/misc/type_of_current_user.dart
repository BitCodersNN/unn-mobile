import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/user_data_provider.dart';

class TypeOfCurrenUser {
  final UserDataProvider _userDataProvider =
      Injector.appInstance.get<UserDataProvider>();
  final GettingProfileOfCurrentUser _gettingProfileOfCurrentUser =
      Injector.appInstance.get<GettingProfileOfCurrentUser>();
  Type? _typeOfUser;

  /// Возвращает тип текущего пользователя: [Type] ([StudentData] или [EmployeeData])
  Future<Type> getTypeOfCurrentUser() async {
    if (_typeOfUser == null) {
      UserData? type = await _userDataProvider.getUserData() ??
          await _gettingProfileOfCurrentUser.getProfileOfCurrentUser();
      _typeOfUser = type.runtimeType;
    }
    return _typeOfUser!;
  }
}
