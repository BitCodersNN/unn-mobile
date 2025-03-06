import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/core/providers/interfaces/data_provider.dart';

abstract interface class UserDataProvider implements DataProvider<UserData?> {
  /// Получает данные профиля пользователя из хранилища
  ///
  /// Возвращает объект [UserData] или null, если в хранилище нет сохранённого профиля
  @override
  Future<UserData?> getData();

  /// Сохраняет данные профиля пользователя
  @override
  Future<void> saveData(UserData? userData);

  /// Проверяет наличие данных профиля пользователя в хранилище
  @override
  Future<bool> isContained();
}
