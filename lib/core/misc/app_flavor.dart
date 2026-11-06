// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/services.dart';

enum AppFlavor({this.store, this.isTesting = false}) {
  regular(),
  regularTest(isTesting: true),
  rustore(store: 'RuStore'),
  rustoreTest(store: 'RuStore', isTesting: true),
  googlePlay(store: 'Google Play'),
  googlePlayTest(store: 'Google Play', isTesting: true);

  final String? store;
  final bool isTesting;

  factory AppFlavor.fromString(String? flavor) => switch (flavor) {
    'defaultStable' => AppFlavor.regular,
    'defaultTest' => AppFlavor.regularTest,
    'RuStoreStable' => AppFlavor.rustore,
    'RuStoreTest' => AppFlavor.rustoreTest,
    'GooglePlayStable' => AppFlavor.googlePlay,
    'GooglePlayTest' => AppFlavor.googlePlayTest,
    _ => AppFlavor.regular,
  };

  factory AppFlavor.current() => AppFlavor.fromString(appFlavor);

  String getFormattedVersion(String version, String buildNumber) {
    final additionals = [?store, if (isTesting) 'тестовая сборка $buildNumber'];
    if (additionals.isNotEmpty) {
      return '$version (${additionals.join(', ')})';
    }
    return version;
  }
}
