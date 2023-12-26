import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/models/student_data.dart';
import 'package:unn_mobile/core/models/employee_data.dart';

abstract interface class GettingProfileOfCurrentUser {
  /// Получает профиль текущего пользователя
  /// 
  /// Возвращает [StudentData] или [EmployeeData] - наследников [UserData] или null,
  /// если не вышло получить ответ от портала или statusCode не равен 200
  Future<UserData?> getProfileOfCurrentUser();
}
