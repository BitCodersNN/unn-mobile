// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/services.dart';

enum AppFlavor {
  regular,
  regularTest,
  rustore,
  rustoreTest,
  googlePlay,
  googlePlayTest;

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

  String getFormattedVersion(String version, String buildNumber) =>
      switch (this) {
        AppFlavor.regular => version,
        AppFlavor.regularTest => '$version (тестовая сборка $buildNumber)',
        AppFlavor.rustore => '$version (RuStore)',
        AppFlavor.rustoreTest =>
          '$version (RuStore, тестовая сборка $buildNumber)',
        AppFlavor.googlePlay => '$version (Google Play)',
        AppFlavor.googlePlayTest =>
          '$version (Google Play, тестовая сборка $buildNumber)',
      };
}
