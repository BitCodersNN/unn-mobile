import 'package:unn_mobile/core/models/auth_data.dart';


abstract interface class AuthDataProvider {
  /// Получает данные, необходимые для авторизации из хранилища
  /// 
  /// Возращает объект AuthData, содержащий логин и пароль пользователя
  Future<AuthData> getAuthData();
  // Сохраняет данные, необходимые для авторизации в хранилище
  Future<void> saveAuthData(AuthData authData);
}