// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/birthday/birthday_greeting_data.dart';

class _BirthdayGreetingCatalogJsonKeys {
  static const String greetings = 'greetings';
}

class BirthdayGreetingCatalog {
  final List<BirthdayGreetingData> greetings;

  BirthdayGreetingCatalog({
    required Iterable<BirthdayGreetingData> greetings,
  }) : greetings = List.unmodifiable(greetings) {
    if (this.greetings.isEmpty ||
        this.greetings.map((greeting) => greeting.id).toSet().length !=
            this.greetings.length) {
      throw const FormatException(
        'Birthday greetings must have unique IDs and cannot be empty',
      );
    }
  }

  factory BirthdayGreetingCatalog.fromJson(Object? json) {
    if (json is! JsonMap) {
      throw const FormatException(
        'Expected a birthday greetings configuration',
      );
    }
    return BirthdayGreetingCatalog(
      greetings: (json[_BirthdayGreetingCatalogJsonKeys.greetings]! as List)
          .map((item) => BirthdayGreetingData.fromJson(item as JsonMap)),
    );
  }

  JsonMap toJson() => {
        _BirthdayGreetingCatalogJsonKeys.greetings: [
          for (final greeting in greetings) greeting.toJson(),
        ],
      };
}
