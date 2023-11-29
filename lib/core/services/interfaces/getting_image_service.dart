import 'package:image/image.dart';

abstract interface class GettingImage {
  /// Получает изображение текущего пользователя
  ///
  /// Возращает [Image] или null, если у пользователя нет фото или не вышло получить ответ от портала, или statusCode не равен 200
  Future<Image?> getImageOfCurrentUser();

  /// Получает изображение по url
  ///
  /// Возращает [Image] или null, если не вышло получить ответ от портала или statusCode не равен 200
  Future<Image?> getImage(String url);
}
