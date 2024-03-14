import 'package:unn_mobile/core/models/blog_data.dart';

abstract interface class GettingBlogPosts {
/// Получает 50 записей из живой ленты
///
/// [pageNumber]: номер страницы, с которой возьмутся записи
/// (т.е. на 0-ой странице первые 50 записей, на 1-ой - с 50 по 99 запись и т.д.)
/// 
/// Возвращает список [BlogData] или null, если:
///  1. Не вышло получить ответ от портала
///  2. statusCode не равен 200
///  3. Не вышло декодировать ответ
  Future<List<BlogData>?> getBlogPost({int pageNumber = 0});
}
