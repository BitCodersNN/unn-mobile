import 'package:flutter/material.dart';

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

  final String _imagePath;
  final DateTimeRange? _dateTimeRangeToUseOn;
  final String _title;
  final TextStyle _titleStyle;
  final String? _description;
  final TextStyle? _descriptionStyle;

  LoadingPageModel({
    required String imagePath,
    DateTimeRange? dateTimeRangeToUseOn,
    String title = defaultTitle,
    TextStyle titleStyle = defaultTextStyle,
    String? description,
    TextStyle? descriptionStyle,
  })  : _imagePath = imagePath,
        _dateTimeRangeToUseOn = dateTimeRangeToUseOn,
        _title = title,
        _titleStyle = titleStyle,
        _description = description,
        _descriptionStyle = descriptionStyle;

  String get title => _title;
  String get imagePath => _imagePath;
  DateTimeRange? get dateTimeRangeToUseOn => _dateTimeRangeToUseOn;
  String? get description => _description;
  TextStyle get titleStyle => _titleStyle;
  TextStyle? get descriptionStyle => _descriptionStyle;

  factory LoadingPageModel.fromJson(Map<String, dynamic> json) {
    final String imagePath = json[_LoadingPageModelJsonKeys.logoPath];

    final DateTimeRange? dateTimeRange = _getDateTimeRangeFromJson(json);

    final titleJson = json[_LoadingPageModelJsonKeys.title];
    final String title =
        titleJson?[_LoadingPageModelJsonKeys.text] ?? defaultTitle;
    final titleStyle = _getTextStyleFromJson(titleJson) ?? defaultTextStyle;

    final descriptionJson = json[_LoadingPageModelJsonKeys.description];
    final String? description =
        descriptionJson?[_LoadingPageModelJsonKeys.text];

    final descriptionStyle = _getTextStyleFromJson(descriptionJson);

    return LoadingPageModel(
      imagePath: imagePath,
      dateTimeRangeToUseOn: dateTimeRange,
      title: title,
      titleStyle: titleStyle,
      description: description,
      descriptionStyle: descriptionStyle,
    );
  }

  static DateTimeRange? _getDateTimeRangeFromJson(Map<String, dynamic> json) {
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
    Map<String, dynamic>? json, {
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

  Map<String, dynamic> toJson() {
    return {
      _LoadingPageModelJsonKeys.logoPath: _imagePath,
      _LoadingPageModelJsonKeys.startDate:
          _dateTimeRangeToUseOn?.start.toString().substring(5, 10),
      _LoadingPageModelJsonKeys.endDate:
          _dateTimeRangeToUseOn?.end.toString().substring(5, 10),
      _LoadingPageModelJsonKeys.title: {
        _LoadingPageModelJsonKeys.text: _title,
        _LoadingPageModelJsonKeys.color: _titleStyle.color!.value.toString(),
        _LoadingPageModelJsonKeys.fontSize: _titleStyle.fontSize.toString(),
      },
      if (_description != null)
        _LoadingPageModelJsonKeys.description: {
          _LoadingPageModelJsonKeys.text: _description,
          _LoadingPageModelJsonKeys.color:
              _descriptionStyle?.color!.value.toString(),
          _LoadingPageModelJsonKeys.fontSize:
              _descriptionStyle?.fontSize.toString(),
        },
    };
  }
}
