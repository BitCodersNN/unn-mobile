import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';

extension AuthRequestResultErrorMessages on AuthRequestResult {
  String get errorMessage => switch (this) {
        AuthRequestResult.success => '',
        AuthRequestResult.wrongCredentials => 'Логин или пароль неверны',
        AuthRequestResult.noInternet => 'Не получилось подключиться к серверу',
        AuthRequestResult.unknownError => 'Случилась неизвестная ошибка',
      };
}
