// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/constants/string_keys/authors_config_keys.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/about/author.dart';

class AuthorsCatalog {
  final List<Author> authors;
  final List<Author> pastAuthors;

  AuthorsCatalog({
    required Iterable<Author> authors,
    required Iterable<Author> pastAuthors,
  })  : authors = List.unmodifiable(authors),
        pastAuthors = List.unmodifiable(pastAuthors);

  AuthorsCatalog withAvatarBaseUrl(String baseUrl) => AuthorsCatalog(
        authors: authors.map((author) => author.withAvatarBaseUrl(baseUrl)),
        pastAuthors:
            pastAuthors.map((author) => author.withAvatarBaseUrl(baseUrl)),
      );

  factory AuthorsCatalog.fromJson(Object? json) {
    final config = json! as JsonMap;
    return AuthorsCatalog(
      authors: (config[AuthorsConfigKeys.authors]! as List)
          .map((item) => Author.fromJson(item as JsonMap)),
      pastAuthors: (config[AuthorsConfigKeys.pastAuthors]! as List)
          .map((item) => Author.fromJson(item as JsonMap)),
    );
  }

  JsonMap toJson() => {
        AuthorsConfigKeys.authors: [
          for (final author in authors) author.toJson(),
        ],
        AuthorsConfigKeys.pastAuthors: [
          for (final author in pastAuthors) author.toJson(),
        ],
      };
}
