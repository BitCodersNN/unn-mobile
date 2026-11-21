// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/hex_color.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';

abstract final class _Keys {
  static const logoPath = 'logo_path';
  static const name = 'name';
  static const startDate = 'start_date';
  static const endDate = 'end_date';
  static const title = 'title';
  static const description = 'description';
  static const text = 'text';
  static const color = 'color';
  static const fontSize = 'fontSize';
  static const themes = 'themes';
  static const common = 'common';
  static const palettes = 'palettes';
}

class LoadingPageModel {
  static const defaultTextStyle = TextStyle(
    fontSize: 34.09,
    fontFamily: 'LetoSans',
  );

  static const defaultTitle = 'СТУДЕНЧЕСКИЙ ХАБ \n ДЛЯ ННГУ \n [НЕОФИЦИАЛЬНЫЙ]';

  final String? imagePath;
  final String title;
  final TextStyle titleStyle;
  final String? description;
  final TextStyle? descriptionStyle;

  const LoadingPageModel({
    this.imagePath,
    this.title = defaultTitle,
    this.titleStyle = defaultTextStyle,
    this.description,
    this.descriptionStyle,
  });
}

class LoadingPageEntry {
  final String? name;
  final String? _startDate;
  final String? _endDate;
  final _LoadingPageAppearance _base;
  final Map<String, _LoadingPageTheme> _themes;

  LoadingPageEntry.fromJson(JsonMap json)
    : name = json[_Keys.name] as String?,
      _startDate = json[_Keys.startDate] as String?,
      _endDate = json[_Keys.endDate] as String?,
      _base = _LoadingPageAppearance.fromJson(json),
      _themes = {
        for (final theme in (json[_Keys.themes] as JsonMap? ?? {}).entries)
          if (theme.value case final JsonMap data)
            theme.key: _LoadingPageTheme.fromJson(data),
      };

  bool get hasDate => _startDate != null && _endDate != null;

  bool matches(DateTime date) {
    final start = _monthDay(_startDate);
    final end = _monthDay(_endDate);
    if (start == null || end == null) {
      return false;
    }

    final day = date.month * 100 + date.day;
    return start <= end
        ? day >= start && day <= end
        : day >= start || day <= end;
  }

  static int? _monthDay(String? value) {
    final parts = value?.split('-');
    if (parts == null || parts.length != 2) {
      return null;
    }
    final month = int.tryParse(parts[0]);
    final day = int.tryParse(parts[1]);
    if (month == null || day == null) {
      return null;
    }
    final date = DateTime.utc(2000, month, day);
    return date.month == month && date.day == day ? month * 100 + day : null;
  }

  Iterable<String> get logoPaths => [
    _base.logoPath,
    for (final theme in _themes.values) ...[
      theme.common.logoPath,
      for (final palette in theme.palettes.values) palette.logoPath,
    ],
  ].nonNulls;

  LoadingPageModel resolve({
    required Brightness brightness,
    required String palette,
    String? fallbackLogo,
  }) {
    final themed = _themes[brightness.name]?.appearanceFor(palette);
    final base = brightness == Brightness.dark
        ? _base.withoutTextColors
        : _base;
    final appearance = base.merge(themed);
    return LoadingPageModel(
      imagePath: appearance.logoPath ?? fallbackLogo,
      title: appearance.title.text ?? LoadingPageModel.defaultTitle,
      titleStyle: LoadingPageModel.defaultTextStyle.merge(
        appearance.title.style,
      ),
      description: appearance.description.text,
      descriptionStyle: LoadingPageModel.defaultTextStyle.merge(
        appearance.description.style,
      ),
    );
  }

  JsonMap toJson() => {
    ..._base.toJson(),
    if (name != null) _Keys.name: name,
    if (_startDate != null) _Keys.startDate: _startDate,
    if (_endDate != null) _Keys.endDate: _endDate,
    if (_themes.isNotEmpty)
      _Keys.themes: _themes.map((key, theme) => MapEntry(key, theme.toJson())),
  };
}

class _LoadingPageTheme {
  final _LoadingPageAppearance common;
  final Map<String, _LoadingPageAppearance> palettes;

  _LoadingPageTheme.fromJson(JsonMap json)
    : common = _LoadingPageAppearance.fromJson(
        json[_Keys.common] as JsonMap? ?? const {},
      ),
      palettes = {
        for (final palette in (json[_Keys.palettes] as JsonMap? ?? {}).entries)
          if (palette.value case final JsonMap data)
            palette.key: _LoadingPageAppearance.fromJson(data),
      };

  _LoadingPageAppearance appearanceFor(String palette) =>
      common.merge(palettes[palette]);

  JsonMap toJson() => {
    _Keys.common: common.toJson(),
    _Keys.palettes: palettes.map(
      (key, appearance) => MapEntry(key, appearance.toJson()),
    ),
  };
}

class _LoadingPageAppearance {
  final String? logoPath;
  final _LoadingPageText title;
  final _LoadingPageText description;

  const _LoadingPageAppearance(this.logoPath, this.title, this.description);

  factory _LoadingPageAppearance.fromJson(JsonMap json) {
    final path = (json[_Keys.logoPath] as String?)?.trim();
    return _LoadingPageAppearance(
      path == null || path.isEmpty ? null : path,
      _LoadingPageText.fromJson(json[_Keys.title] as JsonMap?),
      _LoadingPageText.fromJson(json[_Keys.description] as JsonMap?),
    );
  }

  _LoadingPageAppearance merge(_LoadingPageAppearance? other) => other == null
      ? this
      : _LoadingPageAppearance(
          other.logoPath ?? logoPath,
          title.merge(other.title),
          description.merge(other.description),
        );

  _LoadingPageAppearance get withoutTextColors => _LoadingPageAppearance(
    logoPath,
    title.withoutColor,
    description.withoutColor,
  );

  JsonMap toJson() => {
    if (logoPath != null) _Keys.logoPath: logoPath,
    if (!title.isEmpty) _Keys.title: title.toJson(),
    if (!description.isEmpty) _Keys.description: description.toJson(),
  };
}

class _LoadingPageText {
  final String? text;
  final Color? color;
  final double? fontSize;

  const _LoadingPageText(this.text, this.color, this.fontSize);

  factory _LoadingPageText.fromJson(JsonMap? json) {
    final color = switch (json?[_Keys.color]) {
      final int value => Color(value),
      final String value => _parseColor(value),
      _ => null,
    };
    final fontSize = double.tryParse(json?[_Keys.fontSize]?.toString() ?? '');
    return _LoadingPageText(
      json?[_Keys.text] as String?,
      color,
      fontSize != null && fontSize.isFinite && fontSize > 0 ? fontSize : null,
    );
  }

  static Color? _parseColor(String value) {
    final normalized = value.trim();
    final argb = int.tryParse(normalized);
    return normalized.toLowerCase().startsWith('0x') && argb != null
        ? Color(argb)
        : ColorParser.fromHex(normalized);
  }

  bool get isEmpty => text == null && color == null && fontSize == null;

  TextStyle get style => TextStyle(color: color, fontSize: fontSize);

  _LoadingPageText get withoutColor => _LoadingPageText(text, null, fontSize);

  _LoadingPageText merge(_LoadingPageText other) => _LoadingPageText(
    other.text ?? text,
    other.color ?? color,
    other.fontSize ?? fontSize,
  );

  JsonMap toJson() => {
    if (text != null) _Keys.text: text,
    if (color case final value?) _Keys.color: value.toARGB(),
    if (fontSize != null) _Keys.fontSize: fontSize.toString(),
  };
}
