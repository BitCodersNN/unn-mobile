// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:math';

import 'package:unn_mobile/core/models/birthday/birthday_greeting_catalog.dart';
import 'package:unn_mobile/core/models/birthday/birthday_greeting_data.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/core/providers/interfaces/birthday/birthday_greeting_provider.dart';
import 'package:unn_mobile/core/repositories/interfaces/git/git_resource_repository.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class BirthdayGreetingManager {
  final BirthdayGreetingProvider _provider;
  final LoggerService _logger;
  final GitResourceRepository<BirthdayGreetingCatalog> _catalog;
  final Random _random = Random();

  BirthdayGreetingManager(this._provider, this._logger, this._catalog);

  bool isBirthday(UserData user, DateTime today) {
    final birthdate = user.birthdate;
    return birthdate != null &&
        birthdate.month == today.month &&
        birthdate.day == today.day;
  }

  Future<bool> shouldShow(UserData user, DateTime today) async {
    if (!isBirthday(user, today)) {
      return false;
    }
    int? shownYear;
    try {
      shownYear = await _provider.getShownYear(user.userId);
    } catch (error, stack) {
      _logger.logError(error, stack);
      return false;
    }
    return shownYear != today.year;
  }

  Future<void> markShown(int userId, DateTime date) async {
    try {
      await _provider.saveShownYear(userId, date.year);
    } catch (error, stack) {
      _logger.logError(error, stack);
    }
  }

  Future<BirthdayGreetingData?> getGreeting(
    int userId, {
    String? previousId,
  }) async {
    final greetings = (await _catalog.get())?.data.greetings ?? const [];
    if (greetings.isEmpty) {
      return null;
    }
    String? savedId;
    try {
      savedId = await _provider.getLastGreetingId(userId);
    } catch (error, stack) {
      _logger.logError(error, stack);
    }
    final candidates = greetings
        .where((greeting) => greeting.id != (previousId ?? savedId))
        .toList(growable: false);
    final choices = candidates.isEmpty ? greetings : candidates;
    final selected = choices[_random.nextInt(choices.length)];
    try {
      await _provider.saveLastGreetingId(userId, selected.id);
    } catch (error, stack) {
      _logger.logError(error, stack);
    }
    return selected;
  }
}
