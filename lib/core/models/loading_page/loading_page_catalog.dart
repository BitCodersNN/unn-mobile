// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/loading_page/loading_page_data.dart';

abstract final class _LoadingPageCatalogJsonKeys {
  static const defaults = 'default';
  static const holidays = 'holidays';
  static const facultyDays = 'faculty_days';
  static const legacyPages = 'pages';
}

class LoadingPageCatalog {
  final List<LoadingPageEntry> _defaults;
  final List<LoadingPageEntry> _holidays;
  final List<LoadingPageEntry> _facultyDays;
  final bool isCurrentFormat;

  LoadingPageCatalog._({
    required Iterable<LoadingPageEntry> defaults,
    required Iterable<LoadingPageEntry> holidays,
    required Iterable<LoadingPageEntry> facultyDays,
    this.isCurrentFormat = true,
  }) : _defaults = List.unmodifiable(defaults),
       _holidays = List.unmodifiable(holidays),
       _facultyDays = List.unmodifiable(facultyDays);

  Set<String> get logoPaths => {
    for (final page in [..._defaults, ..._holidays, ..._facultyDays])
      ...page.logoPaths,
  };

  LoadingPageModel? pageForDate(
    DateTime date, {
    required Brightness brightness,
    required String palette,
  }) {
    final defaultPage = _defaults.firstOrNull;
    final page =
        _holidays.where((entry) => entry.matches(date)).firstOrNull ??
        _facultyDays.where((entry) => entry.matches(date)).firstOrNull ??
        defaultPage;
    if (page == null) {
      return null;
    }
    return page.resolve(
      brightness: brightness,
      palette: palette,
      fallbackLogo: identical(page, defaultPage)
          ? null
          : defaultPage
                ?.resolve(brightness: brightness, palette: palette)
                .imagePath,
    );
  }

  factory LoadingPageCatalog.fromJson(Object? json) {
    if (json is JsonMap &&
        !json.containsKey(_LoadingPageCatalogJsonKeys.legacyPages)) {
      return LoadingPageCatalog._(
        defaults: _parseGroup(json[_LoadingPageCatalogJsonKeys.defaults]),
        holidays: _parseGroup(json[_LoadingPageCatalogJsonKeys.holidays]),
        facultyDays: _parseGroup(
          json[_LoadingPageCatalogJsonKeys.facultyDays],
        ),
      );
    }

    final pages = _parseGroup(
      json is JsonMap ? json[_LoadingPageCatalogJsonKeys.legacyPages] : json,
    );
    return LoadingPageCatalog._(
      defaults: pages.where((page) => !page.hasDate),
      holidays: pages.where((page) => page.hasDate),
      facultyDays: const [],
      isCurrentFormat: false,
    );
  }

  static List<LoadingPageEntry> _parseGroup(Object? json) {
    if (json is! List) {
      return const [];
    }
    return [
      for (final item in json)
        if (item is JsonMap) LoadingPageEntry.fromJson(item),
    ];
  }

  JsonMap toJson() {
    if (!isCurrentFormat) {
      return {
        _LoadingPageCatalogJsonKeys.legacyPages: [
          for (final page in [..._defaults, ..._holidays, ..._facultyDays])
            page.toJson(),
        ],
      };
    }
    return {
      _LoadingPageCatalogJsonKeys.defaults: _defaults
          .map((page) => page.toJson())
          .toList(),
      _LoadingPageCatalogJsonKeys.holidays: _holidays
          .map((page) => page.toJson())
          .toList(),
      _LoadingPageCatalogJsonKeys.facultyDays: _facultyDays
          .map((page) => page.toJson())
          .toList(),
    };
  }
}
