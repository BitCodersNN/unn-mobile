// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';

class _BirthdayGreetingJsonKeys {
  static const String id = 'id';
  static const String title = 'title';
  static const String message = 'message';
  static const String shortMessage = 'short_message';
}

class BirthdayGreetingData {
  final String id;
  final String title;
  final String message;
  final String shortMessage;

  const BirthdayGreetingData({
    required this.id,
    required this.title,
    required this.message,
    required this.shortMessage,
  });

  factory BirthdayGreetingData.fromJson(JsonMap json) => BirthdayGreetingData(
        id: _readText(json, _BirthdayGreetingJsonKeys.id),
        title: _readText(json, _BirthdayGreetingJsonKeys.title),
        message: _readText(json, _BirthdayGreetingJsonKeys.message),
        shortMessage: _readText(json, _BirthdayGreetingJsonKeys.shortMessage),
      );

  JsonMap toJson() => {
        _BirthdayGreetingJsonKeys.id: id,
        _BirthdayGreetingJsonKeys.title: title,
        _BirthdayGreetingJsonKeys.message: message,
        _BirthdayGreetingJsonKeys.shortMessage: shortMessage,
      };

  static String _readText(JsonMap json, String key) =>
      (json[key]! as String).trim();
}
