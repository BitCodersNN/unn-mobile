// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/core/providers/interfaces/birthday/birthday_greeting_provider.dart';
import 'package:unn_mobile/core/services/interfaces/birthday/birthday_greeting_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class BirthdayGreetingServiceImpl implements BirthdayGreetingService {
  final BirthdayGreetingProvider _provider;
  final LoggerService _logger;

  BirthdayGreetingServiceImpl(this._provider, this._logger);

  @override
  bool isBirthday(UserData user, DateTime today) {
    final birthdate = user.birthdate;
    return birthdate != null &&
        birthdate.month == today.month &&
        birthdate.day == today.day;
  }

  @override
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

  @override
  Future<void> markShown(int userId, DateTime date) async {
    try {
      await _provider.saveShownYear(userId, date.year);
    } catch (error, stack) {
      _logger.logError(error, stack);
    }
  }
}
