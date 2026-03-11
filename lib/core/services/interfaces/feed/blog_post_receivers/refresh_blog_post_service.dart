// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/models/feed/blog_post_type.dart';

abstract interface class RefreshBlogPostService {
  /// Обновляет список постов, выполняя полную перезагрузку контента.
  ///
  /// Отправляет AJAX-запрос на сервер с флагом перезагрузки [reload],
  /// получает HTML-разметку новой ленты постов и парсит её в структурированные объекты.
  ///
  /// Параметры:
  /// - [assetsCheckSum]: Контрольная сумма.
  /// - [signedParameters]: Строка подписанных параметров для безопасности запроса.
  /// - [commentFormUID]: Уникальный идентификатор формы комментариев.
  Future<Map<BlogPostType, List<BlogPost>>?> refreshBlogPosts({
    required String assetsCheckSum,
    required String signedParameters,
    required String commentFormUID,
  });
}
