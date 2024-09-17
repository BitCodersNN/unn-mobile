import 'package:flutter/material.dart';

class _KeysForLoadingPageModelJsonConverter {

}

class LoadingPageModel {
  final String _imagePath;
  final DateTimeRange? _showDateTimeRange;
  final String _title;
  final TextStyle _titleStyle;
  final String? _description;
  final TextStyle? _descriptionStyle;

  LoadingPageModel({
    required String imagePath,
    DateTimeRange? showDateTimeRange,
    String title = 'УНИВЕРСИТЕТ \n ЛОБАЧЕВСКОГО',
    TextStyle titleStyle = const TextStyle(
      color: Color(0xFF0F68AA),
      fontSize: 34.09,
      fontFamily: 'LetoSans',
    ),
    String? description,
    TextStyle? descriptionStyle,
  }):
  _imagePath = imagePath,
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
    final String imagePath = json['logo_path'];
    final String? startDateStr = json['start_date'];
    final String? endDateStr = json['end_date'];

    DateTimeRange? dateTimeRange;
    if (startDateStr != null && endDateStr != null) {
      final now = DateTime.now();
      final yearString = now.year.toString();

      final startDate = DateTime.parse('$yearString-$startDateStr');
      final endDate = DateTime.parse('$yearString-$endDateStr');
      dateTimeRange = DateTimeRange(start: startDate, end: endDate);
    }

    final String title = json['title']?['text'] ?? 'УНИВЕРСИТЕТ \n ЛОБАЧЕВСКОГО';
    final Color titleColor = Color(int.parse(json['title']?['color'] ?? '0xFF0F68AA'));
    final double titleFontSize = double.parse(json['title']?['fontSize'] ?? '34.09');
    final TextStyle titleStyle = TextStyle(
      color: titleColor,
      fontSize: titleFontSize,
      fontFamily: 'LetoSans',
    );

    final String? description = json['description']?['text'];
    final Color? descriptionColor = json['description']?['color'] != null
        ? Color(int.parse(json['description']['color']))
        : null;
    final double? descriptionFontSize = json['description']?['fontSize'] != null
        ? double.parse(json['description']['fontSize'])
        : null;
    final TextStyle? descriptionStyle = description != null
        ? TextStyle(
            color: descriptionColor ?? const Color(0xFF0F68AA),
            fontSize: descriptionFontSize ?? 25.0,
            fontFamily: 'LetoSans',
          )
        : null;

    return LoadingPageModel(
      imagePath: imagePath,
      showDateTimeRange: dateTimeRange,
      title: title,
      titleStyle: titleStyle,
      description: description,
      descriptionStyle: descriptionStyle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logo_path': _imagePath,
      'start_date': _showDateTimeRange?.start.toString().substring(5, 10),
      'end_date': _showDateTimeRange?.end.toString().substring(5, 10),
      'title': {
        'text': _title,
        'color': _titleStyle.color!.value.toRadixString(16),
        'fontSize': _titleStyle.fontSize.toString(),
      },
      if (_description != null)
        'description': {
          'text': _description,
          'color': _descriptionStyle?.color!.value.toRadixString(16),
          'fontSize': _descriptionStyle?.fontSize.toString(),
        },
    };
  }
}
