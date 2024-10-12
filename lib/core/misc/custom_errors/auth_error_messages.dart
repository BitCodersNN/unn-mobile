part of 'library.dart';

extension AuthRequestResultErrorMessages on AuthRequestResult {
  String get errorMessage => switch (this) {
        AuthRequestResult.success => '',
        AuthRequestResult.wrongCredentials => 'Логин или пароль неверны',
        AuthRequestResult.noInternet => 'Не получилось подключиться к серверу',
        AuthRequestResult.unknown => 'Неизвестная ошибка'
      };
}
