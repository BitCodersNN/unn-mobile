// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/loading_page/loading_page_data.dart';

abstract final class _Keys {
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
    return page?.resolve(
      brightness: brightness,
      palette: palette,
      fallbackLogo: defaultPage
          ?.resolve(brightness: brightness, palette: palette)
          .imagePath,
    );
  }

  factory LoadingPageCatalog.fromJson(Object? json) {
    if (json is JsonMap && !json.containsKey(_Keys.legacyPages)) {
      return LoadingPageCatalog._(
        defaults: _parseGroup(json[_Keys.defaults]),
        holidays: _parseGroup(json[_Keys.holidays]),
        facultyDays: _parseGroup(json[_Keys.facultyDays]),
      );
    }

    final pages = _parseGroup(json is JsonMap ? json[_Keys.legacyPages] : json);
    return LoadingPageCatalog._(
      defaults: pages.where((page) => !page.hasDate),
      holidays: pages.where((page) => page.hasDate),
      facultyDays: const [],
      isCurrentFormat: false,
    );
  }

  static List<LoadingPageEntry> _parseGroup(Object? json) =>
      (json as List? ?? const [])
          .map((item) => LoadingPageEntry.fromJson(item as JsonMap))
          .toList();

  JsonMap toJson() => {
    _Keys.defaults: _defaults.map((page) => page.toJson()).toList(),
    _Keys.holidays: _holidays.map((page) => page.toJson()).toList(),
    _Keys.facultyDays: _facultyDays.map((page) => page.toJson()).toList(),
  };
}
