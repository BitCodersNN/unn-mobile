// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/loading_page/loading_page_data.dart';

class _LoadingPageCatalogJsonKeys {
  static const String pages = 'pages';
}

class LoadingPageCatalog {
  final List<LoadingPageModel> pages;

  LoadingPageCatalog(Iterable<LoadingPageModel> pages)
      : pages = List.unmodifiable(pages) {
    if (this.pages.isEmpty ||
        !this.pages.any((page) => page.dateTimeRangeToUseOn == null)) {
      throw const FormatException('Loading pages must contain a default page');
    }
  }

  LoadingPageModel pageForDate(DateTime date) => pages.firstWhere(
        (page) =>
            page.dateTimeRangeToUseOn != null &&
            date.isDateInRangeIgnoringYear(page.dateTimeRangeToUseOn!),
        orElse: () =>
            pages.firstWhere((page) => page.dateTimeRangeToUseOn == null),
      );

  factory LoadingPageCatalog.fromJson(Object? json) {
    if (json is! List && json is! JsonMap) {
      throw const FormatException('Expected a loading pages configuration');
    }
    final items = json is List
        ? json
        : (json! as JsonMap).values.expand((group) => group! as List);
    return LoadingPageCatalog(
      items.map((item) => LoadingPageModel.fromJson(item as JsonMap)),
    );
  }

  JsonMap toJson() => {
        _LoadingPageCatalogJsonKeys.pages: [
          for (final page in pages) page.toJson(),
        ],
      };
}
