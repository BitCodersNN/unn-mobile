import 'package:unn_mobile/core/models/user_data.dart';

abstract interface class UserDataProvider {
  /// Получает данные профиля пользователя из хранилища
  /// 
  /// Возвращает объект [UserData] или null, если в хранилище нет сохранённого профиля
  Future<UserData?> getUserData();
  // Сохраняет данные профиля пользователя
  Future<void> saveUserData(UserData userData);
}
