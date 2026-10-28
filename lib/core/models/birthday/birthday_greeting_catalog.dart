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
  }) : greetings = List.unmodifiable(greetings);

  factory BirthdayGreetingCatalog.fromJson(Object? json) {
    final config = json! as JsonMap;
    return BirthdayGreetingCatalog(
      greetings: (config[_BirthdayGreetingCatalogJsonKeys.greetings]! as List)
          .map((item) => BirthdayGreetingData.fromJson(item as JsonMap)),
    );
  }

  JsonMap toJson() => {
        _BirthdayGreetingCatalogJsonKeys.greetings: [
          for (final greeting in greetings) greeting.toJson(),
        ],
      };
}
