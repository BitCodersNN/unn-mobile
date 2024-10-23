import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/feed/blog_post_data.dart';

abstract interface class FeedUpdaterService with ChangeNotifier {
  List<BlogPostData> get feedPosts;
  int get lastLoadedPage;

  /// Обновляет ленту блоговых постов, начиная с первой страницы.
  ///
  /// Этот метод сбрасывает текущую ленту и загружает первую страницу постов.
  Future<void> updateFeed();

  /// Загружает следующую страницу блоговых постов.
  ///
  /// Этот метод увеличивает номер последней загруженной страницы и загружает
  /// соответствующую страницу постов. Если загрузка уже выполняется, метод ничего не делает.
  Future<void> loadNextPage();
}
