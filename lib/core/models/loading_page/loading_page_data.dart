// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/hex_color.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';

class _LoadingPageModelJsonKeys {
  static const String logoPath = 'logo_path';
  static const String startDate = 'start_date';
  static const String endDate = 'end_date';
  static const String title = 'title';
  static const String description = 'description';
  static const String text = 'text';
  static const String color = 'color';
  static const String fontSize = 'fontSize';
}

class LoadingPageModel {
  static const defaultTextStyle = TextStyle(
    color: Color(0xFF0F68AA),
    fontSize: 34.09,
    fontFamily: 'LetoSans',
  );

  static const defaultTitle = 'УНИВЕРСИТЕТ \n ЛОБАЧЕВСКОГО';

  final String imagePath;
  final DateTimeRange? dateTimeRangeToUseOn;
  final String title;
  final TextStyle titleStyle;
  final String? description;
  final TextStyle? descriptionStyle;

  LoadingPageModel({
    required this.imagePath,
    this.dateTimeRangeToUseOn,
    this.title = defaultTitle,
    this.titleStyle = defaultTextStyle,
    this.description,
    this.descriptionStyle,
  });

  factory LoadingPageModel.fromJson(JsonMap json) {
    final titleJson = json[_LoadingPageModelJsonKeys.title] as JsonMap?;
    final descriptionJson =
        json[_LoadingPageModelJsonKeys.description] as JsonMap?;

    return LoadingPageModel(
      imagePath: json[_LoadingPageModelJsonKeys.logoPath],
      dateTimeRangeToUseOn: _getDateTimeRangeFromJson(json),
      title: titleJson?[_LoadingPageModelJsonKeys.text] ?? defaultTitle,
      titleStyle: _getTextStyleFromJson(titleJson) ?? defaultTextStyle,
      description: descriptionJson?[_LoadingPageModelJsonKeys.text],
      descriptionStyle: _getTextStyleFromJson(descriptionJson),
    );
  }

  static DateTimeRange? _getDateTimeRangeFromJson(JsonMap json) {
    final String? startDateStr = json[_LoadingPageModelJsonKeys.startDate];
    final String? endDateStr = json[_LoadingPageModelJsonKeys.endDate];

    DateTimeRange? dateTimeRange;
    if (startDateStr != null && endDateStr != null) {
      final now = DateTime.now();
      final yearString = now.year.toString();

      final startDate = DateTime.parse('$yearString-$startDateStr');
      final endDate = DateTime.parse('$yearString-$endDateStr');
      dateTimeRange = DateTimeRange(start: startDate, end: endDate);
    }

    return dateTimeRange;
  }

  static TextStyle? _getTextStyleFromJson(
    JsonMap? json, {
    TextStyle defaultTextStyle = defaultTextStyle,
  }) {
    if (json == null) {
      return null;
    }

    final colorFromJson = json[_LoadingPageModelJsonKeys.color];
    final colorInt = int.tryParse(
      colorFromJson ?? defaultTextStyle.color.toString(),
    );
    final Color titleColor = Color(colorInt!);

    final fontSizeFromJson = json[_LoadingPageModelJsonKeys.fontSize];

    final fontSize = double.tryParse(
      fontSizeFromJson ?? defaultTextStyle.fontSize.toString(),
    );

    final TextStyle titleStyle = TextStyle(
      color: titleColor,
      fontSize: fontSize,
      fontFamily: defaultTextStyle.fontFamily,
    );

    return titleStyle;
  }

  JsonMap toJson() => {
        _LoadingPageModelJsonKeys.logoPath: imagePath,
        _LoadingPageModelJsonKeys.startDate:
            dateTimeRangeToUseOn?.start.toString().substring(5, 10),
        _LoadingPageModelJsonKeys.endDate:
            dateTimeRangeToUseOn?.end.toString().substring(5, 10),
        _LoadingPageModelJsonKeys.title: {
          _LoadingPageModelJsonKeys.text: title,
          _LoadingPageModelJsonKeys.color: titleStyle.color!.toARGB(),
          _LoadingPageModelJsonKeys.fontSize: titleStyle.fontSize.toString(),
        },
        if (description != null)
          _LoadingPageModelJsonKeys.description: {
            _LoadingPageModelJsonKeys.text: description,
            _LoadingPageModelJsonKeys.color: descriptionStyle?.color!.toARGB(),
            _LoadingPageModelJsonKeys.fontSize:
                descriptionStyle?.fontSize.toString(),
          },
      };
}
