import 'package:flutter/material.dart';

class LoadingPageModel {
  final String _title;
  final TextStyle _titleStyle;
  final String _imagePath;
  final String? _description;
  final TextStyle? _descriptionStyle;

  LoadingPageModel(
      {String title = 'УНИВЕРСИТЕТ \n ЛОБАЧЕВСКОГО',
      TextStyle titleStyle = const TextStyle(
          color: Color.fromRGBO(15, 104, 170, 1.0),
          fontSize: 34.09,
          fontFamily: "LetoSans"),
      required String imagePath,
      String? description,
      TextStyle? descriptionStyle})
      : _title = title,
        _titleStyle = titleStyle,
        _imagePath = imagePath,
        _description = description,
        _descriptionStyle = descriptionStyle;

  String get title => _title;
  String get imagePath => _imagePath;
  String? get description => _description;
  TextStyle get titleStyle => _titleStyle;
  TextStyle? get descriptionStyle => _descriptionStyle;
}
