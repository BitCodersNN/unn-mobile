import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/student_data.dart';
import 'package:unn_mobile/core/models/employee_data.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/user_data_provider.dart';

class TypeOfCurrentUser {
  final UserDataProvider _userDataProvider =
      Injector.appInstance.get<UserDataProvider>();
  final GettingProfileOfCurrentUser _gettingProfileOfCurrentUser =
      Injector.appInstance.get<GettingProfileOfCurrentUser>();

  /// Хранит тип текущего пользователя: [Type] ([StudentData] или [EmployeeData]) или [Null] в случае ошибки
  Type typeOfUser = StudentData;

  /// Получает тип авторизованного пользователя. Возвращает типы ([Type]) [StudentData] или [EmployeeData], или [Null] при ошибке
  Future<Type> getTypeOfCurrentUser() async {
    UserData? type = await _userDataProvider.getData() ??
        await _gettingProfileOfCurrentUser.getProfileOfCurrentUser();
    return type.runtimeType;
  }

  /// Обновляет тип текущего пользователя
  Future<void> updateTypeOfCurrentUser() async {
    typeOfUser = await getTypeOfCurrentUser();
  }
}
