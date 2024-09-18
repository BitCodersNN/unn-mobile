import 'package:flutter/material.dart';

class _KeysForLoadingPageModelJsonConverter {
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
  final DateTimeRange? _showDateTimeRange;
  final String _title;
  final TextStyle _titleStyle;
  final String? _description;
  final TextStyle? _descriptionStyle;

  LoadingPageModel({
    required String imagePath,
    DateTimeRange? showDateTimeRange,
    String title = defaultTitle,
    TextStyle titleStyle = defaultTextStyle,
    String? description,
    TextStyle? descriptionStyle,
  })  : _imagePath = imagePath,
        _showDateTimeRange = showDateTimeRange,
        _title = title,
        _titleStyle = titleStyle,
        _description = description,
        _descriptionStyle = descriptionStyle;

  String get title => _title;
  String get imagePath => _imagePath;
  String? get description => _description;
  TextStyle get titleStyle => _titleStyle;
  TextStyle? get descriptionStyle => _descriptionStyle;

  factory LoadingPageModel.fromJson(Map<String, dynamic> json) {
    final String imagePath =
        json[_KeysForLoadingPageModelJsonConverter.logoPath];

    final DateTimeRange? dateTimeRange = _getDateTimeRaneFromJson(json);

    final titleJson = json[_KeysForLoadingPageModelJsonConverter.title];
    final String title =
        titleJson?[_KeysForLoadingPageModelJsonConverter.text] ?? defaultTitle;
    final titleStyle = _getTextStyleFromJson(titleJson) ?? defaultTextStyle;

    final descriptionJson =
        json[_KeysForLoadingPageModelJsonConverter.description];
    final String? description =
        descriptionJson?[_KeysForLoadingPageModelJsonConverter.text];

    final descriptionStyle = _getTextStyleFromJson(descriptionJson);

    return LoadingPageModel(
      imagePath: imagePath,
      showDateTimeRange: dateTimeRange,
      title: title,
      titleStyle: titleStyle,
      description: description,
      descriptionStyle: descriptionStyle,
    );
  }

  static DateTimeRange? _getDateTimeRaneFromJson(Map<String, dynamic> json) {
    final String? startDateStr =
        json[_KeysForLoadingPageModelJsonConverter.startDate];
    final String? endDateStr =
        json[_KeysForLoadingPageModelJsonConverter.endDate];

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

    final colorFromJson = json[_KeysForLoadingPageModelJsonConverter.color];
    final colorInt = int.tryParse(
      colorFromJson ?? defaultTextStyle.color.toString(),
    );
    final Color titleColor = Color(colorInt!);

    final fontSizeFromJson =
        json[_KeysForLoadingPageModelJsonConverter.fontSize];

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
      _KeysForLoadingPageModelJsonConverter.logoPath: _imagePath,
      _KeysForLoadingPageModelJsonConverter.startDate:
          _showDateTimeRange?.start.toString().substring(5, 10),
      _KeysForLoadingPageModelJsonConverter.endDate:
          _showDateTimeRange?.end.toString().substring(5, 10),
      _KeysForLoadingPageModelJsonConverter.title: {
        _KeysForLoadingPageModelJsonConverter.text: _title,
        _KeysForLoadingPageModelJsonConverter.color:
            _titleStyle.color!.value.toRadixString(16),
        _KeysForLoadingPageModelJsonConverter.fontSize:
            _titleStyle.fontSize.toString(),
      },
      if (_description != null)
        _KeysForLoadingPageModelJsonConverter.description: {
          _KeysForLoadingPageModelJsonConverter.text: _description,
          _KeysForLoadingPageModelJsonConverter.color:
              _descriptionStyle?.color!.value.toRadixString(16),
          _KeysForLoadingPageModelJsonConverter.fontSize:
              _descriptionStyle?.fontSize.toString(),
        },
    };
  }
}
