// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:convert';

import 'package:event/event.dart';
import 'package:flutter/foundation.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/constants/string_keys/app_settings_keys.dart';
import 'package:unn_mobile/core/misc/tab_bar_preferences.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class AppSettings {
  static final tabBarPaths =
      ValueNotifier<List<String>>(TabBarPreferences.defaultPaths);

  static Future<void> updateTabBarPaths(List<String> paths) async {
    final normalized = TabBarPreferences.normalize(paths);
    await Injector.appInstance.get<StorageService>().write(
          key: AppSettingsKeys.tabBarPaths,
          value: jsonEncode(normalized),
        );
    tabBarPaths.value = normalized;
    optionsSaved.broadcast();
  }

  static bool vibrationEnabled = true;
  static bool analyticsEnabled = false;
  static bool reverseComments = true;

  static Event optionsSaved = Event('optionsSaved');

  static Future<void> load() async {
    vibrationEnabled = await _readValue(
      AppSettingsKeys.vibrationEnabled,
      defaultValue: true,
      parser: bool.tryParse,
    );
    analyticsEnabled = await _readValue(
      AppSettingsKeys.analyticsEnabled,
      defaultValue: false,
      parser: bool.tryParse,
    );
    reverseComments = await _readValue(
      AppSettingsKeys.reverseComments,
      defaultValue: true,
      parser: bool.tryParse,
    );
    tabBarPaths.value = await _readValue(
      AppSettingsKeys.tabBarPaths,
      defaultValue: TabBarPreferences.defaultPaths,
      parser: (value) {
        try {
          final decoded = jsonDecode(value);
          return decoded is List
              ? TabBarPreferences.normalize(decoded.whereType<String>())
              : null;
        } on FormatException {
          return null;
        }
      },
    );
    optionsSaved.broadcast();
  }

  static Future<T> _readValue<T>(
    String key, {
    required T? Function(String val) parser,
    required T defaultValue,
  }) async {
    final storage = Injector.appInstance.get<StorageService>();
    if (await storage.containsKey(key: key)) {
      return parser(await storage.read(key: key) ?? '') ?? defaultValue;
    }
    return defaultValue;
  }

  static Future<void> save() async {
    final storage = Injector.appInstance.get<StorageService>();
    await storage.write(
      key: AppSettingsKeys.vibrationEnabled,
      value: vibrationEnabled.toString(),
    );
    await storage.write(
      key: AppSettingsKeys.analyticsEnabled,
      value: analyticsEnabled.toString(),
    );
    await storage.write(
      key: AppSettingsKeys.reverseComments,
      value: reverseComments.toString(),
    );

    optionsSaved.broadcast();
  }
}
